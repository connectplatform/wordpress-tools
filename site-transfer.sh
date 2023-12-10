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
    if [ $? -ne 0 ]; then
        echo "Failed to download backup. Exiting."
        exit 1
    fi

    # Extract the backup contents
    tar -xzvf "${sitename}.tar.gz"
    if [ $? -ne 0 ]; then
        echo "Failed to extract backup. Exiting."
        exit 1
    fi

    # Extract database credentials from wp-config.php using awk for consistency
    db_name=$(awk -F"'" '/DB_NAME/{print $4}' wp-config.php)
    db_user=$(awk -F"'" '/DB_USER/{print $4}' wp-config.php)
    db_host=$(awk -F"'" '/DB_HOST/{print $4}' wp-config.php | cut -d ":" -f 1)
    db_port=$(awk -F"'" '/DB_HOST/{print $4}' wp-config.php | cut -d ":" -f 2 | tr -d "'")

    # Debugging: Check current DB_USER and DB_PASSWORD in wp-config.php
    echo "Old DB_USER and DB_PASSWORD:"
    grep "DB_USER" wp-config.php
    grep "DB_PASSWORD" wp-config.php

    echo "Updating wp-config.php with the new database credentials"

    # Generate mysql credentials to comply with security requirements
    generate_name() {
        local length=8
        local num_lower=1
        local num_digits=1

        # Required character sets
        local lower_chars="abcdefghijklmnopqrstuvwxyz"
        local digits_chars="0123456789"

        # Construct the name
        local name=$(cat /dev/urandom | tr -dc "${lower_chars}${digits_chars}" | fold -w ${length} | head -n 1)

        # Ensure the password contains at least one character of each required type
        name=$(echo $name | sed "s/./$(echo $lower_chars | fold -w1 | shuf | head -n1)/$num_lower")
        name=$(echo $name | sed "s/./$(echo $digits_chars | fold -w1 | shuf | head -n1)/$num_digits")

        echo $name
    }

    generate_password() {
        local length=16
        local num_upper=1
        local num_lower=1
        local num_digits=1
        local num_special=1

        # Required character sets
        local upper_chars="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        local lower_chars="abcdefghijklmnopqrstuvwxyz"
        local digits_chars="0123456789"
        local special_chars="@#$%"

        # Construct the password
        local password=$(cat /dev/urandom | tr -dc "${upper_chars}${lower_chars}${digits_chars}${special_chars}" | fold -w ${length} | head -n 1)

        # Ensure the password contains at least one character of each required type
        password=$(echo $password | sed "s/./$(echo $upper_chars | fold -w1 | shuf | head -n1)/$num_upper")
        password=$(echo $password | sed "s/./$(echo $lower_chars | fold -w1 | shuf | head -n1)/$num_lower")
        password=$(echo $password | sed "s/./$(echo $digits_chars | fold -w1 | shuf | head -n1)/$num_digits")
        password=$(echo $password | sed "s/./$(echo $special_chars | fold -w1 | shuf | head -n1)/$num_special")

        echo $password
    }
    
    # Generate a user name and update wp-config.php
    db_name=$(generate_name)
    sed -i "s|define('DB_NAME', '.*');|define('DB_NAME', '$db_name');|" wp-config.php
    if [ $? -ne 0 ]; then
        echo "Failed to update DB_NAME in wp-config.php. Exiting."
        exit 1
    fi

    # Generate a user name and update wp-config.php
    db_user=$(generate_name)
    sed -i "s|define('DB_USER', '.*');|define('DB_USER', '$db_user');|" wp-config.php
    if [ $? -ne 0 ]; then
        echo "Failed to update DB_USER in wp-config.php. Exiting."
        exit 1
    fi

    # Generate a complex password and update wp-config.php
    db_password=$(generate_password)
    sed -i "s|define('DB_PASSWORD', '.*');|define('DB_PASSWORD', '$db_password');|" wp-config.php
    if [ $? -ne 0 ]; then
        echo "Failed to update DB_PASSWORD in wp-config.php. Exiting."
        exit 1
    fi

    # Debugging: Check if DB_NAME and DB_USER have been updated in wp-config.php
    echo "New DB_NAME and DB_USER:"
    grep "DB_NAME" wp-config.php
    grep "DB_PASSWORD" wp-config.php

    # Check if a port number is available
    if [ -z "$db_port" ]; then
        # No port number found, default to 3306
        db_port=3306
    fi

    # Ask for MySQL root password
    read -sp "Enter MySQL root password for $db_host: " root_password
    echo ""

    # Log in to MySQL and create the database, user, and assign privileges
    mysql -u root -p$root_password -h $db_host -P $db_port -e "
    CREATE DATABASE IF NOT EXISTS $db_name;
    CREATE USER IF NOT EXISTS '$db_user'@'%' IDENTIFIED BY '$db_password';
    GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'%';
    FLUSH PRIVILEGES;"
    if [ $? -ne 0 ]; then
        echo "Failed to create database or user. Exiting."
        exit 1
    fi

    # Extract the database backup
    tar -xzvf db_backup.tar.gz

    # Import the database
    mysql -u $db_user -p$db_password -h $db_host -P $db_port $db_name < db_backup.sql
    if [ $? -ne 0 ]; then
        echo "Failed to import database. Exiting."
        exit 1
    fi

    # Delete the downloaded and extracted backup files
    rm "${sitename}.tar.gz" db_backup.tar.gz db_backup.sql

    echo "$sitename restored successfully."
    ;;
    *)
        echo "Invalid option, select 1 or 2"
        read -p "Press any key to continue..." key
        exec $0
        ;;
esac
