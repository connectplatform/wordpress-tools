#!/bin/bash

echo "This script needs to be launched in the public www directory of the website we are about to restore on a new server."

# Prompt user for the site name
read -p "Enter website URL that you are transferring (without https://): " sitename

# Download the backup
wget "https://${sitename}/${sitename}.tar.gz"

# Extract the backup contents
tar -xzvf "${sitename}.tar.gz"

# Extract database credentials from wp-config.php
db_name=$(grep DB_NAME wp-config.php | cut -d "'" -f 4)
db_user=$(grep DB_USER wp-config.php | cut -d "'" -f 4)
db_password=$(grep DB_PASSWORD wp-config.php | cut -d "'" -f 4)
db_host=$(grep DB_HOST wp-config.php | cut -d "'" -f 4)

# Ask for MySQL root password
read -sp "Enter MySQL root password for $db_host: " root_password
echo ""

# Log in to MySQL and create the database, user, and assign privileges
mysql -u root -p$root_password -h $db_host -e "
CREATE DATABASE IF NOT EXISTS $db_name;
CREATE USER IF NOT EXISTS '$db_user'@'%' IDENTIFIED BY '$db_password';
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'%';
FLUSH PRIVILEGES;"

# Extract the database backup
tar -xzvf db_backup.tar.gz

# Import the database
mysql -u $db_user -p$db_password $db_name < db_backup.sql

echo "Restoration of $sitename completed."
