# WordPress Tools

This repository contains various free scripts for WordPress site management and migration.

## WordPress Site Transfer

The `site-transfer.sh` script is designed to automate the process of migrating a WordPress site from one server to another. It performs a series of actions to ensure a smooth transfer:

- **On the source server**, it identifies the WordPress installation directory, exports the database to a SQL file, compresses the database and WordPress files into a single archive, and prepares it for transfer.
- **On the destination server**, it retrieves the compressed archive, decompresses it, imports the database content to a new database, and adjusts the WordPress configuration to match the new environment.

### Prerequisites

- SSH access to both source and destination servers
- `wget` installed on both servers

### Usage

#### On the Source Server

1. Navigate to the root directory of your current WordPress site (where `wp-config.php` is located).
2. Download `site-transfer.sh` using the following command and make it executable:

   ```sh
   wget https://raw.githubusercontent.com/connectplatform/wordpress-tools/main/site-transfer.sh && chmod +x site-transfer.sh
   ```

3. Run the script and choose option 1 to create a backup:

   ```sh
   ./site-transfer.sh
   ```

#### On the Destination Server

1. Navigate to the public directory where you plan to move your WordPress site (next to your future wp-config.php).
2. Download `site-transfer.sh` as described above.
3. Run the script and choose option 2 to restore the site:

   ```sh
   ./site-transfer.sh
   ```


## MySQL Database Optimization

The `optimize-db.sh` script is designed to automatically optimize all tables in a WordPress database. Regular optimization of the database can help improve performance by defragmenting the database storage. This is particularly beneficial for sites with frequent updates or deletions.

### Prerequisites

- SSH access to the server where the WordPress site is hosted.
- MySQL user credentials with the necessary privileges to perform optimizations (typically the same credentials used by WordPress in `wp-config.php`).

### Usage

1. **Download the Script:**
   Download `db-optimizer.sh` to the root directory of your WordPress installation (where `wp-config.php` is located).

   ```sh
   wget https://raw.githubusercontent.com/connectplatform/wordpress-tools/main/db-optimizer.sh && chmod +x db-optimizer.sh
   ```

2. **Run the Script:**

   ```sh
   ./db-optimizer.sh
   ```

### Scheduling with Cron

To automate the database optimization process, you can schedule the `db-optimizer.sh` script to run at a specific time using cron. For example, to run the script at 5 AM every three days, you would add the following cron job:

1. Open your crontab for editing:

   ```sh
   crontab -e
   ```
   
2. Add the following line to the crontab file (use 'crontab -e' to edit crontab):

   ```sh
   0 5 */3 * * /path/to/wordpress/db-optimizer.sh
   ```
   Replace /path/to/wordpress/ with the actual path to your WordPress installation directory.

3. Save and close the crontab file. The cron daemon will automatically pick up this new job and run the script at the specified time.

### Important Notes
- **Performance Impact:** Be aware that running this script can temporarily impact the performance of your WordPress site, as the OPTIMIZE TABLE command locks tables during optimization. It's recommended to run this script during low-traffic periods, for example, at 5AM.

## MyISAM to InnoDB Conversion

The `myisam2innodb.sh` script is designed to transition all MyISAM tables in a given WordPress database to the InnoDB storage engine. The InnoDB engine provides better performance and reliability for WordPress sites, particularly those utilizing WooCommerce, by supporting advanced features such as transactional data integrity and row-level locking.

### Prerequisites

- SSH access to the server where the WordPress site is hosted.
- MySQL or MariaDB root or equivalent user credentials.
- The `wp-config.php` file must be present in the directory from which the script is executed, as it is used to extract the database name.

### Overview

This script performs the following operations:

1. **Extracts the Database Name:** Reads the `wp-config.php` file to find the WordPress database name.
2. **Database Backup:** Creates a full backup of the WordPress database, naming the file after the database with a `-backup.sql` suffix. This step is crucial for data safety, allowing recovery in case of any issues during the conversion process.
3. **Converts Tables:** Converts all tables from MyISAM to InnoDB, ensuring that the database is fully compatible with the InnoDB engine for improved performance and stability.

### Usage

1. **Prepare the Script:**
   - Download `myisam2innodb.sh` into the root directory of your WordPress site (where `wp-config.php` is located).
   - Make the script executable:

     ```sh
      wget https://raw.githubusercontent.com/connectplatform/wordpress-tools/main/myisam2innodb.sh && chmod +x myisam2innodb.sh
     ```

2. **Execute the Script:**
   - Run the script by typing:

     ```sh
     ./myisam2innodb.sh
     ```

   - When prompted, enter the MySQL/MariaDB root password.

### Important Notes

- **Data Safety:** The script starts by creating a backup of your database. Ensure you have enough disk space for this backup.
- **Downtime Consideration:** While the conversion process is generally quick, large databases might experience a brief downtime. Plan to run this script during low-traffic periods.
- **Performance Monitoring:** After conversion, monitor your site's performance. Consider adjusting your MySQL/MariaDB configuration to optimize InnoDB performance, such as tuning `innodb_buffer_pool_size`.

## Contributing

Contributions to enhance the functionality of these scripts are welcome. Please feel free to fork the repository, make your changes, and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

Ray Sorkin [LinkedIn](https://linkedin.com/in/raysorkin) [Twitter](https://twitter.com/ray_sorkin) [Telegram](https://t.me/ray_sorkin)