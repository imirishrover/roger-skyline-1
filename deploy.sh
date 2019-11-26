#!bin/bash
#This script should be executed on the server. If you unable to copy this file
#there just do all this commands manually

sudo apt update && sudo apt -y upgrade
sudo apt-get install ufw portsentry fail2ban apache2 mailutils -y

#this file contains configurations to connect via ssh and have internet via NAT adapter
mv 01-netcfg.yaml /etc/netplan/
sudo netplan apply

sudo apt-get install -y openssh-server

#switch default ssh port to 2222 port
sudo sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config

