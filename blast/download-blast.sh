#!/bin/bash
#sabryr 06-05-2021
module purge
module load BLAST+/2.11.0-gompi-2020b
module load Perl/5.32.0-GCCcore-10.2.0

for db in $(cat db.list )
do
        echo "Now processing "$db"  started "
        date
        update_blastdb.pl --decompress --timeout=600 $db
        sleep 60
done
