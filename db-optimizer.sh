#!/bin/bash

# Script to perform MySQL database optimization and repair

echo "Starting MySQL Database Optimization and Repair."

# Extract database credentials from wp-config.php
db_name=$(awk -F"'" '/DB_NAME/{print $4}' wp-config.php)
db_user=$(awk -F"'" '/DB_USER/{print $4}' wp-config.php)
db_password=$(awk -F"'" '/DB_PASSWORD/{print $4}' wp-config.php)
db_host_and_port=$(awk -F"'" '/DB_HOST/{print $4}' wp-config.php)

# Separate host and port if port is specified
IFS=':' read -ra ADDR <<< "$db_host_and_port"
db_host=${ADDR[0]}
db_port=${ADDR[1]}

# Check if a port number is available
port_param=""
if [ ! -z "$db_port" ]; then
    port_param="-P $db_port"
fi

# Get the list of tables
tables=$(mysql -h "$db_host" $port_param -u "$db_user" -p"$db_password" -D "$db_name" -e 'SHOW TABLES;' | awk '{ print $1}' | grep -v '^Tables')

# Repair and optimize each table
for table in $tables; do
    echo "Repairing table: $table"
    mysql -h "$db_host" $port_param -u "$db_user" -p"$db_password" -D "$db_name" -e "REPAIR TABLE $table"
    
    echo "Optimizing table: $table"
    mysql -h "$db_host" $port_param -u "$db_user" -p"$db_password" -D "$db_name" -e "OPTIMIZE TABLE $table"
done

echo "MySQL Database Optimization and Repair Completed."
