#!/bin/bash
vzctl create 251 --ostemplate centos-6-x86_64 --config basic

vzctl set 251 --vmguarpages 512M --save
vzctl set 251 --oomguarpages 512M --save
vzctl set 251 --privvmpages 512M:1024M --save

# Configure the CT
vzctl set 251 --save --name server251
vzctl set 251 --save --onboot yes
vzctl set 251 --save --hostname server251.example.com
vzctl set 251 --save --searchdomain example.com
vzctl set 251 --save --nameserver 8.8.8.8 --nameserver 8.8.4.4

# add ifcfg-veth251.0 
cat > /etc/sysconfig/network-scripts/ifcfg-veth251.0 << EOF
DEVICE=veth251.0
ONBOOT=no
BRIDGE=vmbr0
EOF

vzctl start 251
/usr/sbin/brctl addif vmbr0 veth251.0

# Configure the OpenVZ Container
cat > /vz/root/251/etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE=eth0
HOSTNAME="server251"
BOOTPROTO=static
IPADDR=192.168.1.251
NETMASK=255.255.255.0
ONBOOT=yes
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
EOF

# we are using static IP, stop NetworkManager, start network
vzctl exec 251 chkconfig NetworkManager off
vzctl exec 251 service NetworkManager stop
vzctl exec 251 chkconfig network on
vzctl exec 251 service network restart
#system-config-network

vzctl exec 251 /sbin/ifconfig eth0 0
vzctl exec 251 /sbin/service network restart


# set password root for OpenVZ container 251
echo "Please enter the new password:"
read -s password1
echo "Please repeat the new password:"
read -s password2

# Check both passwords match
if [ $password1 != $password2 ]; then
    echo "Passwords do not match"
     exit    
fi

while [ $password1 != $password2 ]
do
  echo "Please enter the new password:"
  read -s password1
  echo "Please repeat the new password:"
  read -s password2
done

a_user="root"
its_password=$password1

# Change password
echo -e "$password1\n$password1" | passwd $username
vzctl exec 251 echo "$a_user:$its_password" | chpasswd


echo "OpenVZ Container 251 is created"
