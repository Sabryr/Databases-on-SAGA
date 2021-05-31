#!/bin/bash

######################
# Script made by Oskar Vidarsson <oskar.vidarsson@uib.no>
# Usage: ./db-updater.sh {blast,busco,kraken2}
# This script will update the blast, busco or kraken2 databases
######################

trap exit SIGKILL ERR SIGTERM SIGINT

set -e
set -o nounset  # Treat any unset variables as an error
#set -x

startMsg () {
	echo "Started database update on $(date)"
}

finishMsg () {
	echo "Finished updating database on $(date)"
}

mkdest() {
	# Variable and path to the directory with the latest database
	today="$(date +%Y-%m-%d)"
	dest=/cluster/shared/databases/$1/$today

	mkdir -p $dest
	cd $dest
}

symlinkDB () {
	ln -sfn $dest $(dirname $dest)/latest
}

buscoUpdate () {
	mkdest "BUSCO"

	# Make list of databases to download
	curl https://busco-data.ezlab.org/v4/data/lineages/ |\
	grep href | \
	grep gz | \
	awk -F "\"" '{print "https://busco-data.ezlab.org/v4/data/lineages/"$2}'> \
	downloadlist.txt

	# Download databases
	while read -r dldb; do
	        wget -c $dldb
#	done < <(head -n 1 downloadlist.txt)
	done < downloadlist.txt

	# Unpack and delete if unpacking was successful
	dbs=(*.tar.gz)
	for db in ${dbs[@]}; do
		tar -zxvf $db && \
		rm ${db}
	done
}

blastUpdate () {
	# Set the working directory
	wd=/cluster/shared/databases/blast/scripts/

	mkdest "blast"

	# While loop that reads the db.list file and downloads the updated
	# databases
	while read -r db; do
		echo "Downloading "$db""
		date
		perl $wd/update_blastdb-05-17.pl --decompress --timeout=600 $db
		echo "$db database was downloaded"
		echo "Sleeping for 20 seconds"
		sleep 20
#	done < <(head -n 1 $wd/db.list)
	done < $wd/db.list
}

kraken2Update () {
	mkdest "Kraken2"

	krakenBuild='/cluster/shared/databases/Kraken2/kraken2/kraken2-build'

	echo "Downloading new database to $dest"

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

main
