#!/bin/bash
######################
# Script made by Oskar Vidarsson <oskar.vidarsson@uib.no>
# Usage: ./prune-databases.sh
# Description:
# Find directories 90 days or older and delete them, but only if there are 
# 4 or more directories. This avoids the deletion of all databases if they 
# for some reason aren't updated anymore
######################

set -e
set -o nounset
#set -x

echo "$(date "+%D at %H:%M") - Searching for old databases to delete"

for dir in blast Kraken2 BUSCO AWS-iGenomes; do
	cd /cluster/shared/databases/$dir

	# Check if there are any directories 90 days or older, then check 
	# if there are 4 or more directories named based on the [0-9]* 
	# pattern

	databases=$(find . -mindepth 1 -maxdepth 1 -type d -name "202[0-9]-[0-1][0-9]-[0-3][0-9]" | wc -l)
	nrOldFolder=$(find . -mindepth 1 -maxdepth 1 -type d -name "202[0-9]-[0-1][0-9]-[0-3][0-9]" -mtime +90 | wc -l)

	if [[ $nrOldFolder -ge 1 && $databases -gt 3 ]]; then
		echo "Will delete the following in the $dir directory: "
		find . -mindepth 1 -maxdepth 1 -type d -name "202[0-9]-[0-1][0-9]-[0-3][0-9]" -mtime +90
		find . -mindepth 1 -maxdepth 1 -type d -name "202[0-9]-[0-1][0-9]-[0-3][0-9]" -mtime +90 -execdir rm -r {} +
	else
		echo "No folder older than 90 days found in the $dir directory"
		echo "No backup to delete"
	fi
done
