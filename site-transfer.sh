#!/bin/bash

echo "Welcome to Sonoratek WP-transfer script."
echo "This script is designed to effortlessly migrate a Wordpress-powered website to another host."
echo "Select your desired action:"
echo "1. Backup this wordpress website including its database."
echo "2. Restore a wordpress archive from another server."

read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        # Backup WordPress Site

        # Extract database credentials from wp-config.php
        db_name=$(awk -F"'" '/DB_NAME/{print $4}' wp-config.php)
        db_user=$(awk -F"'" '/DB_USER/{print $4}' wp-config.php)
        db_password=$(awk -F"'" '/DB_PASSWORD/{print $4}' wp-config.php)
        db_host=$(awk -F"'" '/DB_HOST/{print $4}' wp-config.php | cut -d ":" -f 1)
        db_port=$(awk -F"'" '/DB_HOST/{print $4}' wp-config.php | cut -d ":" -f 2 | tr -d "'")

        # Check if a port number is available
        if [ -z "$db_port" ]; then
            # No port number found, default to 3306
            db_port=3306
        fi

        # Dump the database
        mysqldump -h "$db_host" -P "$db_port" -u "$db_user" -p"$db_password" "$db_name" > db_backup.sql

        # Check if mysqldump was successful
        if [ $? -eq 0 ]; then
            echo "Database dumped successfully."

            # Extract the site name from the SQL dump file
            # This command assumes that the 'siteurl' is stored in a standard format in the SQL dump
            sitename=$(grep "siteurl" db_backup.sql | awk -F"'" '{print $4}' | head -1 | awk -F"/" '{print $3}')

            # Compress the database dump
            tar -czvf db_backup.tar.gz db_backup.sql

            # Remove the uncompressed database dump
            rm db_backup.sql

            # Compress the entire WordPress directory, excluding the tarball itself
            echo "Compressing files, please wait..."
            tar --exclude="${sitename}.tar.gz" --exclude="site-transfer.sh" -czf "${sitename}.tar.gz" .

            # Delete the database archive after successful creation of sitename.tar.gz
            rm db_backup.tar.gz

            echo "Backup of $sitename completed."
        else
            echo "Failed to dump database, please check the credentials and try again."
        fi
        ;;
    2)
        # Restore WordPress Site
        echo "This script needs to be launched in the public www directory of the website we are about to restore on a new server."
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

        # Delete the downloaded and extracted backup files
        rm "${sitename}.tar.gz" db_backup.tar.gz

        echo "Restoration of $sitename completed."
        ;;
    *)
        echo "Invalid option, select 1 or 2"
        read -p "Press any key to continue..." key
        exec $0
        ;;
esac
