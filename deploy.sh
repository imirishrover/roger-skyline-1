#!bin/bash

sudo apt update && sudo apt -y upgrade

sudo apt-get install ufw portsentry fail2ban apache2 mailutils -y

mv 01-netcfg.yaml /etc/netplan/

sudo netplan apply




sudo apt install -y openssh-server

sudo sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config

