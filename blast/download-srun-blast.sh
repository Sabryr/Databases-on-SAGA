#!/bin/bash
#sabryr 24-10-2019
version=0.1

echo "Downloading $1"
echo "Using $SLURM_NTASKS cores"
echo "started on $(date)"
module purge
module load BLAST+/2.11.0-gompi-2020b
module load Perl/5.32.0-GCCcore-10.2.0
cd $2
echo "SLURM_NTASKS: $SLURM_NTASKS"

update_blastdb.pl --decompress --timeout=600  $1

exit 0
