# This quick installation quide assumes you have CentOS 6 64-bit installed with SELinux and Firewall disabled, and that the containers will be on the same subnet as the host node.
# The node's IP is 192.168.1.99/24 and the gateway is 192.168.1.1. The containers will have 192.168.1.101, 192.168.1.102, etc...
# Add the OpenVZ yum repo

wget -O /etc/yum.repos.d/openvz.repo http://download.openvz.org/openvz.repo
rpm --import http://download.openvz.org/RPM-GPG-Key-OpenVZ

# Ensure the yum repo points to RHEL6 packages
# cat /etc/yum.repos.d/openvz.repo

# Install the OpenVZ kernel and ensure it's the 1st option in grub
yum install vzkernel

# this is always default
# nano /boot/grub/menu.lst

# Install the OpenVZ utilities
yum install vzctl vzquota

echo 'Changing around some config files..'
sed -i 's/kernel.sysrq = 0/kernel.sysrq = 1/g' /etc/sysctl.conf
sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g' /etc/sysctl.conf

echo 'net.ipv4.conf.default.proxy_arp = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.rp_filter = 1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.send_redirects = 1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.send_redirects = 0' >> /etc/sysctl.conf
echo 'net.ipv4.icmp_echo_ignore_broadcasts=1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.forwarding=1' >> /etc/sysctl.conf
# The last 2 steps are necessary only if you are planning on using veth containers

# Create a vmbr0 bridge and add the host's interface to it
cat > /etc/sysconfig/network-scripts/ifcfg-vmbr0 << EOF
DEVICE=vmbr0
BOOTPROTO=static
IPADDR=192.168.1.104
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
IPV6INIT=no
#BOOTPROTO=dhcp
ONBOOT=yes
TYPE=Bridge
DELAY=0
STP=no
NM_CONTROLLED=NO
EOF

# nano /etc/sysconfig/network-scripts/ifcfg-eth0 	
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE=eth0
HWADDR=00:1e:37:56:60:80
ONBOOT=yes
BOOTPROTO=none
IPV6INIT=no
TYPE=Ethernet
NM_CONTROLLED=no
BRIDGE=vmbr0
EOF

# If use bridge on CentOS 6.x
# NetworkManager must be turn off eachboot
# network must be turn on each boot
service NetworkManager stop
chkconfig NetworkManager off
chkconfig network on
service network restart


# Create /etc/vz/vznet.conf with the following content. This will automatically add/remove the container's interface to the bridge when you start/stop the container.
cat > /etc/vz/vznet.conf << EOF
#!/bin/bash
EXTERNAL_SCRIPT="/usr/sbin/vznetaddbr"
EOF

# Disable SE Linux
sed -i 's/SELINUX=enabled/SELINUX=disabled/g' /etc/sysconfig/selinux

# Install OpenVZ Complete. You should reboot.

echo You should download OpenVZ template as below
echo cd /vz/template/cache
echo wget http://download.openvz.org/template/precreated/centos-6-x86_64.tar.gz
echo wget http://download.openvz.org/template/precreated/ubuntu-13.10-x86_64.tar.gz

