#!/bin/bash
vzctl create 253 --ostemplate centos-6-x86_64 --config basic

vzctl set 253 --vmguarpages 512M --save
vzctl set 253 --oomguarpages 512M --save
vzctl set 253 --privvmpages 512M:1024M --save

# Configure the CT
vzctl set 253 --save --name server253
vzctl set 253 --save --onboot yes
vzctl set 253 --save --hostname server253.example.com
vzctl set 253 --save --searchdomain example.com
vzctl set 253 --save --nameserver 8.8.8.8 --nameserver 8.8.4.4

# add ifcfg-veth253.0 
echo "DEVICE=veth253.0" > /etc/sysconfig/network-scripts/ifcfg-veth252.0
echo "ONBOOT=no" >> /etc/sysconfig/network-scripts/ifcfg-veth252.0
echo "BRIDGE=vmbr0" >> /etc/sysconfig/network-scripts/ifcfg-veth252.0


vzctl start 253
/usr/sbin/brctl addif vmbr0 veth253.0

# Set passwd
# vzctl exec 253 passwd
# skip, go to below part

# Configure the OpenVZ Container
# /usr/sbin/vzctl enter 253

vzctl exec 253 echo "DEVICE=eth0" > /etc/sysconfig/network-scripts/ifcfg-eth0
vzctl exec 253 echo "HOSTNAME=\"server253\"" >> /etc/sysconfig/network-scripts/ifcfg-eth0
vzctl exec 253 echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-eth0
vzctl exec 253 echo "IPADDR=192.168.1.253" >> /etc/sysconfig/network-scripts/ifcfg-eth0
vzctl exec 253 echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-eth0
vzctl exec 253 echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0
vzctl exec 253 echo "GATEWAY=192.168.1.1" >> /etc/sysconfig/network-scripts/ifcfg-eth0
vzctl exec 253 echo "DNS1=8.8.8.8" >> /etc/sysconfig/network-scripts/ifcfg-eth0
vzctl exec 253 echo "DNS2=8.8.4.4" >> /etc/sysconfig/network-scripts/ifcfg-eth0


# we are using static IP, stop NetworkManager, start network
vzctl exec 253 chkconfig NetworkManager off
vzctl exec 253 service NetworkManager stop
vzctl exec 253 chkconfig network on
vzctl exec 253 service network restart
#system-config-network

vzctl exec 253 /sbin/ifconfig eth0 0
vzctl exec 253 /sbin/service network restart


# set password root for OpenVZ container 253
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

# Change password
# echo -e "$password1\n$password1" | passwd $username
vzctl exec 253 echo -e "$password1\n$password1" | passwd root

echo "OpenVZ Container 253 is created"
