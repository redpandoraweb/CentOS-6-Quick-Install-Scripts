echo 'Going to install the Apache + php-fpm + mod_fascgi + mongoDB + mysqlon your machine, here we go...'
echo '------------------------'

echo Install Apache + PHP
yum -y install httpd php php-mysql php-gd php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc

echo Open port 80 in firewall
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save
echo "YOU SHOULD  DO \"service iptables restart\" IF YOU HAVE FIREWALL"

echo Start, auto startup, Apache + php-fpm
service httpd start
chkconfig httpd on
chkconfig --levels 235 php-fpm on
/etc/init.d/php-fpm start

echo mod_fastcgi is available in the RPMforge repositories. enable RPMforge:
rpm --import http://dag.wieers.com/rpm/packages/RPM-GPG-KEY.dag.txt
cd /tmp
wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
rpm -ivh rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm

echo php-fpm is only available from the Remi RPM repository which itself depends on the EPEL repository; we can enable both repositories as follows:
sudo rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

echo Install yum-priorities
yum -y install yum-priorities

echo change /etc/yum.repos.d/epel.repo... and add the line priority=10 to the [epel] section
sed -i '/enabled=1/a\priority=10' /etc/yum.repos.d/epel.repo

echo do the same for the [remi] section in /etc/yum.repos.d/remi.repo, plus change enabled to 1
sed -i '/\[remi\]/,/enabled=0/ { s/enabled=0/enabled=1/ }' /etc/yum.repos.d/remi.repo

echo Instal php-fpm and mod_fastcgi
yum -y install php-fpm mod_fastcgi

echo Configure Apache to use mod_fastcgi
sed -i 's/FastCgiWrapper On/FastCgiWrapper Off/g' /etc/httpd/conf.d/fastcgi.conf
 
echo -e "<IfModule mod_fastcgi.c>\nDirectoryIndex index.html index.shtml index.cgi index.php\nAddHandler php5-fcgi .php\nAction php5-fcgi /php5-fcgi\nAlias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi\nFastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -host 127.0.0.1:9000 -pass-header Authorization\n</IfModule>" >> /etc/httpd/conf.d/fastcgi.conf
 
mkdir /usr/lib/cgi-bin/

# fix permissions
chown -R apache:apache /var/run/mod_fastcgi

# disable mod_php
sed -i 's/LoadModule php5_module/\#LoadModule php5_module/g;s/AddHandler/\#AddHandler/g;s/AddType/\#AddType/g;' /etc/httpd/conf.d/php.conf

# Restart Apache
/etc/init.d/httpd restart

echo 'Going to install MongoDB for ...'

echo '[10gen]' >> /etc/yum.repos.d/10gen.repo
echo 'name=10gen Repository' >> /etc/yum.repos.d/10gen.repo
echo 'baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64' >> /etc/yum.repos.d/10gen.repo
echo 'gpgcheck=0' >> /etc/yum.repos.d/10gen.repo
echo 'enabled=1' >> /etc/yum.repos.d/10gen.repo

yum install -y mongo-10gen mongo-10gen-server

service mongod start
chkconfig mongod on

echo 'Install MongoRock'
wget http://rockmongo.com/release/rockmongo-1.1.5.zip
unzip rockmongo-1.1.5.zip
cp rockmongo /var/www/html
echo 'visit the index.php in your browser, for example: http://localhost/rockmongo/index.php;'
echo 'Login with admin username and password, which is set "admin" and "admin" as default'

clear
echo 'MongoDB is installed, running and set to auto-start on reboots.... your still a NoSQL groupie...'

echo 'Now install MongoDB php driver'
yum -y install php-devel php-pear
yum -y install git
yum -y install gcc
cd ~
git clone https://github.com/mongodb/mongo-php-driver
cd mongo-php-driver
phpize
./configure
make
make install
echo 'If all went well, the mongo.so should be installed in /usr/lib64/php/modules/'
cd /etc/php.d
echo "extension=mongo.so" >> mongo.ini
service httpd restart
echo 'MongoDB php driver installed'

echo 'Now install mySQL'
read -p "MySQL Password: " mysqlPassword
read -p "Retype password: " mysqlPasswordRetype

yum install -y mysql mysql-server
chkconfig mysql-server on
/etc/init.d/mysqld restart

while [[ "$mysqlPassword" = "" && "$mysqlPassword" != "$mysqlPasswordRetype" ]]; do
  echo -n "Please enter the desired mysql root password: "
  stty -echo
  read -r mysqlPassword
  echo
  echo -n "Retype password: "
  read -r mysqlPasswordRetype
  stty echo
  echo
  if [ "$mysqlPassword" != "$mysqlPasswordRetype" ]; then
    echo "Passwords do not match!"
  fi
done

/usr/bin/mysqladmin -u root password $mysqlPassword

clear
echo 'Okay.... apache, php and mysql is installed, running and set to your desired password'

echo 'Now instal PHP-myadmin'
yum -y install phpmyadmin

# Set IP which can access php-myadmin, set "Allow from all" to allow all IP  
sed -i 's/Allow from 127.0.0.1/Allow from all/g' /etc/httpd/conf.d/phpmyadmin.conf

# fill some blowfish secret word here:
sed -i "s/\['blowfish_secret'\] = ''/\['blowfish_secret'\] = 'blowfish'/g" /usr/share/phpmyadmin/config.inc.php

service httpd restart

echo 'Now install VsFTP'
yum -y install vsftpd ftp

sed -i 's/anonymous_enable=YES/anonymous_enable=NO/g' /etc/vsftpd/vsftpd.conf
sed -i 's/\#local_enable=YES/local_enable=YES/g' /etc/vsftpd/vsftpd.conf
sed -i 's/\#chroot_local_user=YES/chroot_local_user=YES/g' /etc/vsftpd/vsftpd.conf

sudo service vsftpd restart
chkconfig vsftpd on

echo 'Install php module need by LampCMS'
yum -y install php-mbstring php-curl php-gd php-pecl-oauth php-pdo php-pdo_mysql php

cat > /var/www/html/info.php << EOF
<?php phpinfo();  ?>
EOF

echo 'Install complete'
