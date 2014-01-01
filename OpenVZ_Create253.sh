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
cat > /etc/sysconfig/network-scripts/ifcfg-veth252.0 << EOF
DEVICE=veth253.0
ONBOOT=no
BRIDGE=vmbr0
EOF

vzctl start 253
/usr/sbin/brctl addif vmbr0 veth253.0

# Set passwd
# vzctl exec 253 passwd
# skip, go to below part

# Configure the OpenVZ Container
/usr/sbin/vzctl enter 253

cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE=eth0
HOSTNAME="server253"
BOOTPROTO=static
IPADDR=192.168.1.253
NETMASK=255.255.255.0
ONBOOT=yes
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
EOF

# we are using static IP, stop NetworkManager, start network
chkconfig NetworkManager off
service NetworkManager stop
chkconfig network on
service network restart
#system-config-network

/sbin/ifconfig eth0 0
/sbin/service network restart


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
echo -e "$password1\n$password1" | passwd root

exit
