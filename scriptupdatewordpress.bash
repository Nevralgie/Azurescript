#!/bin/bash 
# Updating wordpress through your ubuntu terminal. Edit the wordpress directory path with your own. 

sudo apt install unzip
sudo rsync -Waq /var/www/html/wordpress /home/azuretom
sudo rm -rf /var/www/html/wordpress/wp-includes
sudo rm -rf /var/www/html/wordpress/wp-admin
sudo rm -rf /var/www/html/wordpress/wp-content
cd /tmp/ && wget https://wordpress.org/latest.zip
unzip latest.zip
sudo mv /tmp/wordpress/* /var/www/html/wordpress

# Then go to http://www.example.com/wordpress/wp-admin/upgrade.php to automatically initiate the update. 
