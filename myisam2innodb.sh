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
mysqldump -u root -p"$rootpassword" "$dbname" > "${dbname}-backup-$(date +%Y%m%d%H%M%S).sql"

# Check if the dump was successful
if [ $? -eq 0 ]; then
    echo "Backup created successfully."
else
    echo "Failed to create backup. Please check your root password and try again."
    exit 1
fi
# Fetch the list of MyISAM tables
myisam_tables=$(mysql -u root -p"$rootpassword" -D "$dbname" -e "SELECT table_name FROM information_schema.tables WHERE table_schema = '$dbname' AND engine = 'MyISAM'" -s -N)

# Check if we successfully fetched the table list
if [ $? -eq 0 ]; then
    echo "Fetched list of MyISAM tables."
else
    echo "Failed to fetch list of MyISAM tables. Please check the error message above."
    exit 1
fi

# Iterate over the list of tables and convert each to InnoDB
for table in $myisam_tables; do
    echo "Converting $table to InnoDB..."
    mysql -u root -p"$rootpassword" -D "$dbname" -e "ALTER TABLE $table ENGINE=InnoDB;"
    
    if [ $? -eq 0 ]; then
        echo "$table converted successfully."
    else
        echo "Failed to convert $table. Please check the error message above."
        # Optionally, exit on error
        # exit 1
    fi
done
