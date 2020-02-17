#!/bin/bash
yum -y install httpd
echo "This is ASG from HaiNT's terraform" >> /var/www/html/index.html
service httpd start
chkconfig httpd on
service iptables stop
mkfs.ext4 /dev/xvdh
mount /dev/xvdh /mnt
echo /dev/xvdh /mnt defaults,nofail 0 2 >> /etc/fstab