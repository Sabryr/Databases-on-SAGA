#!/bin/bash

#SBATCH --job-name=Kraken2_db_build
#SBATCH --account=nn9997k
#SBATCH --time=1-00:10:00
#SBATCH --mail-type=END --mail-user=sabryr@uio.no
#SBATCH --nodes=1 --partition=bigmem
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --mem-per-cpu=100G

set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

module --quiet purge  # Reset the modules to the system default
module load Kraken2/2.1.1-foss-2020b-Perl-5.32.0

export DBNAME=/cluster/shared/databases/Kraken2/xxx

echo "Started"

kraken2-build --build --threads 6 --db $DBNAME
