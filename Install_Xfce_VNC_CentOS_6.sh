echo 'Install xfce4 + TigerVNC-Server + Firefox + Flash on Centos 6.2'

echo 'Enter root mode'
su
echo 'Install EPEL & RPMI & YUM-Priorities'
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
yum -y install yum-priorities nano
yum update
 
echo 'Enable epel and remi repo'
sed -i '/enabled=1/a\priority=10' /etc/yum.repos.d/epel.repo
sed -i '/\[remi\]/,/enabled=0/ { s/enabled=0/enabled=1/ }' /etc/yum.repos.d/remi.repo
 
yum -y groupinstall xfce
yum -y install tigervnc-server
yum -y install fontforge

cat > /etc/sysconfig/vncservers << EOF
VNCSERVERS="1:root"
VNCSERVERARGS[1]="-geometry 1024x768"
EOF

#nano /etc/sysconfig/vncservers


#VNCSERVERS="1:root"
#VNCSERVERARGS[1]="-geometry 1024x768"

#useradd admin
#su admin


#vncpasswd
#vncserver

#nano /root/.vnc/xstartup
#nano /home/admin/.vnc/xstartup

echo 'Set password for root user'
vncpasswd

service vncserver restart
service vncserver stop

cat > /root/.vnc/xstartup << EOF
#!/bin/sh
/usr/bin/startxfce4
EOF

chmod +x ~/.vnc/xstartup

chkconfig vncserver on

service vncserver restart

#yum -y install firefox
#Flash Player
#rpm -ivh http://linuxdownload.adobe.com/linux/i386/adobe-release-i386-1.0-1.noarch.rpm
#rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
#yum check-update
#yum install flash-plugin

echo 'INSTALL VNC SERVER COMPLETE'
