#!/bin/bash
sudo -s
yum -y install httpd
systemctl start httpd.service
amazon-linux-extras install epel -y
yum -y install stress
echo "This is ASG from HaiNT's terraform" >> /var/www/html/index.html
yum -y install iptables-services
systemctl stop iptables
