#!/bin/bash
# This a script to deploy a fonctionnal web-server with wordpress connected to an Azure Mariadb service (SAAS).

#!/bin/bash
# We install a lamp-server so we can get apache and php directly.
sudo apt update && sudo apt install lamp-server^ -y
# mariadb installation
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash
sudo apt-get install mariadb-server mariadb-client -y
sudo apt install unzip
cd /tmp/ && wget https://wordpress.org/latest.zip
unzip latest.zip
cd /tmp/wordpress
# wp-cli tool install to interact with wordpress with specific commands
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
sudo wp cli update
# Login to our Azure mariadb SAAS mariadb to create a database
sudo mariadb --user=rooTomadmin@tomdbmaria77 --password=@Azurev69007 --host=tomdbmaria77.mariadb.database.azure.com -e "create database wordtest;"
sudo cp -p wp-config-sample.php /home
sudo mv /home/wp-config-sample.php /tmp/wordpress/wp-config.php
sudo wp config set DB_NAME wordtest --allow-root
sudo wp config set DB_USER rooTomadmin@tomdbmaria77 --allow-root
sudo wp config set DB_HOST tomdbmaria77.mariadb.database.azure.com --allow-root
sudo wp config set DB_PASSWORD @Azurev69007 --allow-root
sudo cp -R /tmp/wordpress /var/www/html/wordpress
# Give ownership to the default Apache User
sudo chown -R www-data:www-data /var/www/html/wordpress

