# Databases-on-SAGA

## Basic usage
Assuming that everything has been setup as described below, the basic operation is `./db-update.sh blast` to update the blast database manually, substitute `blast` for `busco` or `kraken2` to update them.

## Basic setup of the database updating script 
N.B these instructions assume that nothing has been installed on saga yet.                                                                                                                        

### Preparatory setup
1. Clone this repository `git clone https://github.com/Sabryr/Databases-on-SAGA` into `/cluster/shared/databases/admin/`
1. Run `cp -r blast Kraken2 BUSCO /cluster/shared/databases/` to copy the database directories to the proper directory on Saga
    * N.B This major update does not include any code for updating the AWS-iGenomes database, any future updates of this database must be done manually
1. To setup kraken2 you must do the following  
    * `cd /cluster/shared/databases/Kraken2/`
    * `git clone https://github.com/DerrickWood/kraken2/`
    * `cd kraken2`
    * `./install_kraken2.sh /cluster/shared/databases/Kraken2/kraken2/`
1. Run `crontab -e` and paste the lines below in it

```bash
20 02 1 */3 * /cluster/shared/databases/admin/Databases-on-SAGA/db-updater.sh blast >> /cluster/shared/databases/admin/Databases-on-SAGA/logs/blast.log 2>&1
20 02 2 */3 * /cluster/shared/databases/admin/Databases-on-SAGA/db-updater.sh busco >> /cluster/shared/databases/admin/Databases-on-SAGA/logs/busco.log 2>&1                                                
20 02 3 */3 * /cluster/shared/databases/admin/Databases-on-SAGA/db-updater.sh kraken2 >> /cluster/shared/databases/admin/Databases-on-SAGA/logs/kraken2.log 2>&1                                            
```
This will create three cronjobs that will run every 3 months at 02:20 on the 1st, 2nd and 3rd day of the month respectively.

### Hardcoded paths
The `db-updater.sh` script has a couple of hardcoded paths that don't need to be changed as long as the instructions above are followed.  
But here's a description of the paths in case they do need to be changed:

1. The mkdest function will create a directory in `/cluster/shared/databases/databaseName/todaysDate`, each new database is downloaded to this directory                                                    
1. The symlinkDB function makes a fresh symlink of the new database to `latest` in the `/cluster/shared/databases/databaseName/` directory  
1. The blastUpdate function sets its working directory to `/cluster/shared/databases/blast/scripts/`  
1. The kraken2Update function is dependent on the kraken2 git repository having been cloned to and compiled in the `/cluster/shared/databases/Kraken2/` directory  
1. There's a file named `db.list` in the `/cluster/shared/databases/Kraken2/` directory  

These steps could probably be simplified by using variables and a config file, but for now this is how it is.

### Other
Good to know for blast: `update_blastdb.pl --showall  > db.list` creates a list of all databases.

## Database pruning script
Since no more than two old versions of each database should exist, and the databases get updated every 3 months, the `prune-databases.sh` script will take care of deleting old databases when there are more than 3 databases and one is older than 3 months  
This is done automatically with a cron job that is setup as such:                                                                                                                                           
Run `crontab -e`, then put the following line in it:                                                                                                                                                        
```bash
20 02 4 */3 * /cluster/shared/databases/admin/Databases-on-SAGA/prune-databases.sh >> /cluster/shared/databases/admin/Databases-on-SAGA/logs/pruner.log 2>&1
``` 
This will create a cronjob that runs every 3 months at 02:20 on the 4th of the month.

### Comments
* The script will cd to `/cluster/shared/databases/databaseName` to check for old databases to remove.  
* It will only delete directories with the naming pattern `202[0-9]-[0-1][0-9]-[0-3][0-9]`, this will for instance delete a directory named `2023-10-30` as long as it is 90 days or older and there are at least 4 directories of that pattern.

Please open an issue if you have any questions.  
