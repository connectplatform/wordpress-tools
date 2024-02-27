#!/bin/bash

# Extract the database name from wp-config.php
dbname=$(grep DB_NAME wp-config.php | cut -d "'" -f 4)

echo "Database name extracted: $dbname"

# Prompt for the MySQL root password
echo -n "Enter MySQL root password: "
read -s rootpassword
echo

# Dump the current database
echo "Creating backup of the database..."
mysqldump -u root -p"$rootpassword" "$dbname" > "${dbname}-backup.sql"

# Check if the dump was successful
if [ $? -eq 0 ]; then
    echo "Backup created successfully."
else
    echo "Failed to create backup. Please check your root password and try again."
    exit 1
fi

# Convert all MyISAM tables to InnoDB
echo "Converting all MyISAM tables to InnoDB..."
mysql -u root -p"$rootpassword" -D "$dbname" -e "SELECT CONCAT('ALTER TABLE ', table_name, ' ENGINE=InnoDB;') FROM information_schema.tables WHERE table_schema = '$dbname' AND engine = 'MyISAM'" | grep ALTER | mysql -u root -p"$rootpassword" -D "$dbname"

# Check if conversion was successful
if [ $? -eq 0 ]; then
    echo "All MyISAM tables converted to InnoDB successfully."
else
    echo "Failed to convert some or all tables. Please check the error message above."
fi
