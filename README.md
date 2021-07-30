# Databases-on-SAGA

## Basic usage
Assuming that everything has been setup as described below, the basic operation for manual use is `./db-update.sh blast` to update the blast database, substitute `blast` for `busco` or `kraken2` to update them.  

## Basic setup of the database updating script 
N.B these instructions assume that `Databases-on-SAGA` has been installed on `/cluster/shared/databases/admin/`.  

### Preparatory setup
This repository is automatically cloned to `/cluster/shared/databases/admin/` by the ansible play (that as of the publication of this update is not been merged yet) in https://gitlab.sigma2.no/sigma2-ansible/sigma-ansible/roles/db-updater/tasks  
Assuming that the ansible play is in place, these are the manual steps involved for everything to work properly.  

1. `cd /cluster/shared/databases/admin/Databases-on-SAGA`  
1. `cp -r blast Kraken2 BUSCO /cluster/shared/databases/`
1. Setting up Kraken2
    * `cd /cluster/shared/databases/Kraken2/`
    * `git clone https://github.com/DerrickWood/kraken2/`
    * `cd kraken2`
    * `./install_kraken2.sh /cluster/shared/databases/Kraken2/kraken2/`

The ansible play also creates the cron jobs to update the databases and to run the `prune-databases.sh` script.  

### Hardcoded paths
The `db-updater.sh` script has a couple of hardcoded paths that don't need to be changed as long as the instructions above are followed.  
But here's a description of the paths in case they do need to be changed:

1. The `mkdest` function will create a directory in `/cluster/shared/databases/databaseName/todaysDate`, each new database is downloaded to this directory  
1. The `symlinkDB` function makes a fresh symlink of the new database to `latest` in the `/cluster/shared/databases/databaseName/` directory  
1. The `kraken2Update` function is dependent on the kraken2 git repository having been cloned to and compiled in the `/cluster/shared/databases/Kraken2/` directory  

### Database pruning script
Since no more than two old versions of each database should exist, and the databases get updated every 3 months, the `prune-databases.sh` script will take care of deleting old databases when there are more than 3 databases and one is older than 3 months  
The cron job for it is created by the ansible play linked to above.  

Please open an issue if you have any questions.  
