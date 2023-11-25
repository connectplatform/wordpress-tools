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
2. Download `site-transfer.sh` using the following command:

   ```sh
   wget https://raw.githubusercontent.com/connectplatform/wordpress-tools/main/site-transfer.sh
   ```

3. Make the script executable:

   ```sh
   chmod +x site-transfer.sh
   ```

4. Run the script and choose option 1 to create a backup:

   ```sh
   ./site-transfer.sh
   ```

#### On the Destination Server

1. Navigate to the public directory where you plan to move your WordPress site.
2. Download `site-transfer.sh` as described above.
3. Run the script and choose option 2 to restore the site:

   ```sh
   ./site-transfer.sh
   ```

## Contributing

Contributions to enhance the functionality of these scripts are welcome. Please feel free to fork the repository, make your changes, and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

Ray Sorkin [https://linkedin.com/in/raysorkin](LinkedIn)