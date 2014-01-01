echo 'This will install LampCMS software from Web'

su
cd /var/www/html/
wget http://www.lampcms.com/lampcms.zip
unzip lampcms.zip
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
tar -zxvf backup.tar.gz

echo 'user www_data, group www_data'
useradd www_data
passwd www_data
usermod -a -G www-data www-data
chgrp -R www-data /var/www
chmod -R g+w /var/www

# Additionally, you should make the directory and all directories below it "set GID", so that all new files and directories created under /var/www are owned by the www-data group.
#find /var/www -type d -exec chmod 2775 {} \;    

#Find all files in /var/www and add read and write permission for owner and group:
#find /var/www -type f -exec chmod ug+rw {} \;

