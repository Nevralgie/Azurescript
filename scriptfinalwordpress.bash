#!/bin/bash
# This a script to deploy a fonctionnal web-server with wordpress connected to an Azure Mariadb service (SAAS).

# We install a lamp-server so we can get apache and php directly.
sudo apt update && sudo apt install lamp-server^ -y
# mariadb installation
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash
sudo apt-get install mariadb-server mariadb-client -y
sudo apt install wordpress -y
sudo service mysql restart
# wp-cli tool install to interact with wordpress with specific commands
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
wp --info
sudo wp cli update
# Login to our SAAS mariadb to create a database
sudo mariadb --user=rooTomadmin@tomdbmaria7 --password=@Azurev69007 --host=tomdbmaria7.mariadb.database.azure.com -e "create database wordpresstest;"
cd /
cd usr/share/wordpress
# wp-config.php configuration in relation to our SAAS database
sudo cp -p wp-config-sample.php /home
sudo mv /home/wp-config-sample.php /usr/share/wordpress/wp-config.php
sudo echo "define('FS_METHOD','direct');" >> wp-config.php
sudo wp config set DB_NAME wordpresstest --allow-root
sudo wp config set DB_USER rooTomadmin@tomdbmaria7 --allow-root
sudo wp config set DB_HOST tomdbmaria7.mariadb.database.azure.com --allow-root
sudo wp config set DB_PASSWORD @Azurev69007 --allow-root
sudo cp -R /usr/share/wordpress /var/www/html/wordpress
sudo chown -R www-data:www-data /var/www/html/wordpress
