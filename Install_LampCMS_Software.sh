echo 'This will install LampCMS software from Web'

su
cd /var/www/html/
wget http://www.lampcms.com/lampcms.zip
unzip lampcms.zip

echo 'set user www_data, group www_data for /var/www folder'
useradd www_data
passwd www_data
usermod -a -G www-data www-data
chgrp -R www-data /var/www
chmod -R g+w /var/www

# Additionally, you should make the directory and all directories below it "set GID", so that all new files and directories created under /var/www are owned by the www-data group.
find /var/www -type d -exec chmod 2775 {} \;    

#Find all files in /var/www and add read and write permission for owner and group:
find /var/www -type f -exec chmod ug+rw {} \;

echo 'Set writable permissions for the /logs directory'
chmod -R 770 /var/www/html/logs

echo 'writable permissions for the /www/w directory'
chmod -R 770 /var/www/html/www/w

echo 'In www directory copy bootstrap.dist.php to bootstrap.php'
cp /var/www/html/www/bootstrap.dist.php /var/www/html/www/bootstrap.php

echo 'Rename !config.ini.dist to !config.ini'
cp /var/www/html/www/!config.ini.dist /var/www/html/www/!config.ini

echo 'Rename acl.ini.dist to acl.ini'
cp /var/www/html/www/acl.ini.dist /var/www/html/www/acl.ini

echo 'Install LampCMS software COMPLETED'

echo 'You should edit !config.ini file follow http://www.lampcms.com/documentation.htm#installation'
echo 'For enable geocity as in guide, do as below'
echo "wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity_CSV/GeoLiteCity-latest.zip"
echo "gunzip GeoLiteCity-latest.zip"
