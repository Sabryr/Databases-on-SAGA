#!/bin/bash
######################
# Script made by Oskar Vidarsson <oskar.vidarsson@uib.no> 
# Description: 
# Find directories 90 days or older and delete them, but only if there are 
# 4 or more directories. This avoids the deletion of all databases if they 
# for some reason aren't updated anymore
######################

set -e
set -o nounset
#set -x

echo "$(date "+%D at %H:%M") - Searching for old databases to delete"

db_count() {
        databases=$(find . -mindepth 1 -maxdepth 1 -type d -name "202[0-9]-[0-1][0-9]-[0-3][0-9]" | wc -l)
	folders=()
	while IFS=  read -r -d $'\0'; do
		folders+=("$REPLY")
	done < <(find . -mindepth 1 -maxdepth 1 -type d -name "202[0-9]-[0-1][0-9]-[0-3][0-9]" -mtime +90 -print0 | sort -z -n)
        nrOldFolder=${#folders[@]}
}

for dir in blast Kraken2 BUSCO; do
	cd /cluster/shared/databases/$dir

        # Check if there are any directories 90 days or older, then check 
        # if there are 4 or more directories named based on the 202[0-9]* 
        # pattern

	db_count

	while [[ $nrOldFolder -ge 1 && $databases -gt 3 ]]; do
		echo "deleting /cluster/shared/databases/$dir/${folders[0]//.\/}"
		rm -r ${folders[0]//.\/}
		db_count
	done
	if [[ $databases -le 3 ]]; then
		echo "Only found $databases $dir databases, will not delete anything"
	elif [[ $nrOldFolder -eq 0 ]]; then
		echo "No folder older than 90 days found in the $dir directory"
		echo "No backup to delete"
	fi
done
