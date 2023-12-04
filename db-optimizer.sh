#!/bin/bash

# Script to perform MySQL database optimization

echo "Starting MySQL Database Optimization."

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

# Connect to the MySQL database and perform optimization
mysql -h "$db_host" -P "$db_port" -u "$db_user" -p"$db_password" -D "$db_name" -e "OPTIMIZE TABLE $(mysql -h "$db_host" -P "$db_port" -u "$db_user" -p"$db_password" -D "$db_name" -e 'SHOW TABLES;' | awk '{ print $1}' | grep -v '^Tables' | tr '\n' ',' | sed 's/,$//')"

echo "MySQL Database Optimization Completed."
