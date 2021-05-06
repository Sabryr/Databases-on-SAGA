#!/bin/bash
#sabryr 06-05-2021
for db in $(cat db.list )
do
        echo "Now processing "$db"  started "
        date
        update_blastdb.pl --decompress --timeout=600 $db
        sleep 60
done
