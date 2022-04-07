#!/bin/bash
######################
# Script made by Oskar Vidarsson <oskar.vidarsson@uib.no> 
# Description:
# This script will download a fresh copy of either the blast, busco or kraken2 databases
# Usage:
# ./db-update.sh databaseName
# Valid options are blast, busco and kraken2
######################

###### Basic settings and such
trap exit SIGKILL ERR SIGTERM SIGINT

set -e
set -o nounset # Treat any unset variables as an error
#set -x

DATE=$(date +%F-%H-%M)
LOGFILE=/cluster/shared/databases/admin/Databases-on-SAGA/logs/$1-$DATE.log
exec 3>&1 4>&2
exec &> >(tee -a $LOGFILE) 2>&1

###### Helper functions
startMsg () {
	printf "\n[INFORMATION]: Started database update on $(date)\n"
}

finishMsg () {
	printf "\n[INFORMATION]: Finished updating database on $(date)\n"
}

# Symlink the new database to "latest"
symlinkDB () {
	ln -sfn $dest $(dirname $dest)/latest
}

# Create and cd to the new "blast/year-month-day" folder
mkdest () {
        # Variable and path to the directory with the latest database
        today="$(date +%Y-%m-%d)"
        dest=/cluster/shared/databases/$1/$today

        mkdir -p $dest
        cd $dest
}

dbAgeChecker () {
	dbsAgeOver90=$(find . -maxdepth 1 -name "202[0-9]-[0-9][0-9]-[0-9][0-9]" -type d -mtime +90 | wc -l)
	if (( $dbsAgeOver90 == 3 )); then
		echo "executing main function"
		main
	else
		echo "Newest $database database is less than 90 days old, will not download new database"
		exit
	fi
}

# Make list of databases to download
urlExtractor () {
	mapfile -t urls < <(curl --retry 20 --retry-delay 7200 --connect-timeout 900 "${1}" | \
	grep -o '".*.gz"' | \
	awk -v url="${1}" -F "\"" '{print url$2}')
}

downloader () {
	echo "Downloading ${1}"
	wget --no-check-certificate --retry-connrefused --wait=2h --timeout=900 -Nc --no-verbose ${1}
}

# Unpack and delete if unpacking was successful
archiveExtractor () {
	echo "Decompressing file"
       	tar -zxvf ${1} && \
        rm ${1}
}


###### Database updating functions
buscoUpdate () {
	mkdest "BUSCO"

	urlExtractor "https://busco-data.ezlab.org/v5/data/lineages/"
	for url in ${urls[@]}; do
		downloader ${url}
		archiveExtractor ${url##*/}
		find . -type f -name "*.faa.gz" -exec gunzip {} \;
	done
}

blastUpdate () {
	mkdest "blast"

	urlExtractor https://ftp.ncbi.nlm.nih.gov/blast/db/

	# Loops through all urls in the array from urlExtractor and attempts to download 
	# the files
	for url in ${urls[@]}; do
		n=0
		while [[ "$n" -lt 5 ]]; do

			downloader ${url}
	
			echo "Downloading ${url}.md5"
			downloader ${url}.md5

			echo "Calculating md5sum on ${url##*/}"
			md5=$(md5sum ${url##*/})
			md5=$(awk '{ print $1 }' <<< $md5)

			echo "Comparing md5sums of downloaded file and the value in the .md5 file"
			if [[ "$md5" == "$(awk '{ print $1 }' ${url##*/}.md5)" ]]; then
				# This is a simple hack to fulfill the while clause when the 
				# md5 sums match
				n=6
				archiveExtractor ${url##*/}
				echo "Sleeping for 60 seconds"
				sleep 60
			else
				echo "md5sum not equal, retrying in 60 seconds"
				n=$((n+1))
				echo $n
				sleep 60
			fi
		done
		if [[ "$n" -eq 5 ]]; then
			echo "[WARNING]: Failed to download ${url##*/} or ${url##*/}.md5"
			echo "[WARNING]: Please update database manually to restore the missing file(s)"
			echo "Continuing"
			n=6
		fi
	done
}

kraken2Update () {
	mkdest "Kraken2"

	krakenBuild='/cluster/shared/databases/Kraken2/kraken2/kraken2-build'

	echo "Downloading new databases to $dest"
	while read -r db; do
	        echo "Running dl-library"
		$krakenBuild \
	        --download-library $db \
	        --no-masking \
	        --db $dest

	        echo "running dl-taxonomy"
		$krakenBuild \
	        --download-taxonomy \
	        --db $dest
#	done < <(head -n 1 /cluster/shared/databases/Kraken2/db.list)
	done < /cluster/shared/databases/Kraken2/db.list

	echo "Running build process"
	$krakenBuild --build --threads 10 --db $dest
}

database=$1
main () {
	startMsg

	case $database in
		busco)
			buscoUpdate
		;;

		blast)
			blastUpdate
		;;

		kraken2)
			kraken2Update
		;;

		*)
			echo "ERROR: The provided argument '$database' is not recognized"
			echo "ERROR: Valid arguments are 'busco', 'blast', and 'kraken2'"
			exit 1
		;;
	esac

	symlinkDB

	finishMsg
}

dbAgeChecker
