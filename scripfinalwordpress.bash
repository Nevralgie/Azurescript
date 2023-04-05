#!/bin/bash
sudo apt update && sudo apt install lamp-server^ -y
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash
sudo apt-get install mariadb-server mariadb-client -y
sudo apt install wordpress -y
chown -R www-data:www-data wordpress/
chmod -R 755 wordpress/
sudo service mysql restart
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
wp --info
sudo wp cli update
#Désactiver SSL et autoriser connection NAT gateway dans les firewall rules pour que la ligne suivante fonctionne
sudo mariadb --user=rooTomadmin@tomdbmaria7 --password=@Azurev69007 --host=tomdbmaria7.mariadb.database.azure.com -e "create $
cd /
cd usr/share/wordpress
sudo cp -p wp-config-sample.php /home
sudo mv /home/wp-config-sample.php /usr/share/wordpress/wp-config.php
sudo echo "define('FS_METHOD','direct');" >> wp-config.php
sudo wp config set DB_NAME wordpresstest --allow-root
sudo wp config set DB_USER rooTomadmin@tomdbmaria7 --allow-root
sudo wp config set DB_HOST tomdbmaria7.mariadb.database.azure.com --allow-root
sudo wp config set DB_PASSWORD @Azurev69007 --allow-root
sudo ln -s /usr/share/wordpress /var/www/html/wordpress
sudo chown -R www-data:www-data /var/www/html/wordpress
