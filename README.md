### Wordpress Tools
Various free scripts for Wordpress

## Wordpress site transfer
# site-transfer.sh
1. Login to your both servers via SSH.
2. Download this script with wget to a current wordpress site root directory (where wp-config.php is located) and a to a public directory on a new server where you plan to move your site to.
3. Run this script on the source server with ./site-transfer.sh and select 1 to backup.
4. Run this script on the destination server and select 2 to restore.
