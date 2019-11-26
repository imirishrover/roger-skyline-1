#!bin/bash
#start this script on your local machine if you have stable ssh connection
#IP 192.168.56.2 port 2222

ssh nsance@192.168.56.2 -p 2222
#if connection is established continue
exit

#generate ssh public key
ssh-keygen -t rsa
#copy key to the server
ssh-copy-id -i id_rsa.pub nsance@192.168.56.2 -p 2222

#connect via ssh again. use your public key pass if you use it
ssh nsance@192.168.56.2 -p 2222

sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentification yes/#PasswordAuthentification no/g' /etc/ssh/sshd_config

sudo service ssh restart

#turn on firewall
sudo ufw enable

#allow it to use ssh port, http port and udp port
sudo ufw allow 2222/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443

#install utility which can block ddos attacks
sudo apt-get install fail2ban
exit
##############################################
sudo scp -P 2222 jail.conf nsance@192.168.56.2:/etc/fail2ban/jail.conf
sudo scp -P 2222 http-get-dos.conf nsance@192.168.56.2:/etc/fail2ban/filter.d/

sudo ufw reload
sudo service fail2ban restart


#protect server from port scanning
sudo sed -i 's/TCP_MODE="tcp"/TCP_MODE="atcp"/g' /etc/default/portsentry
sudo sed -i 's/TCP_MODE="udp"/TCP_MODE="audp"/g' /etc/default/portsentry


sudo scp -P 2222 portsentry.conf nsance@192.168.56.2:/etc/portsentry/

sudo service portsentry restart


#disable unused services
sudo systemctl disable console-setup.service
sudo systemctl disable keyboard-setup.service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer
sudo systemctl disable syslog.service


#create script that automatically follow up the updates of all utulities
echo "sudo apt-get update -y >> /var/log/update_script.log" >> ~/roger_files/update.sh
echo "sudo apt-get upgrade -y >> /var/log/update_script.log" >> ~/roger_files/update.sh

#sudo crontab -e

echo "SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin

@reboot sudo ~/update.sh
0 4 * * 6 sudo ~/update.sh
0 0 * * * sudo ~/cronMonitor.sh" >> crontab


#create script that will check actuality of crontab
sudo scp -P 2222 cronMonitor.sh nsance@192.168.56.2:~/roger_files/


#configuring mail
sudo apt-get install postfix mutt

sudo scp -P 2222 main.cf nsance@192.168.56.2:/etc/postfix/

sudo mkdir /etc/postfix/private

echo "@yandex.ru	nsance21@yandex.ru" >> /etc/postfix/private/canonical

echo "@yandex.ru	smtp.yandex.ru" >> /etc/postfix/private/sender_relay

echo "[smtp.yandex.ru]	nsance21@yandex.ru:telecaca37" >> /etc/postfix/private/sasl_passwd

sudo postmap /etc/postfix/private/*
sudo service postfix restart


sudo chmod 755 cronMonitor.sh
sudo chmod 755 update.sh
#sudo chown gde /var/mail/nsance

sudo systemctl enable cron





sudo scp -P 2222 login_site/index.html nsance@192.168.56.2:/var/www/html/
sudo scp -P 2222 login_site/jsfile.js nsance@192.168.56.2:/var/www/html/
sudo scp -P 2222 login_site/style.css nsance@192.168.56.2:/var/www/html/

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=FR/ST=IDF/O=42/OU=Project-roger/CN=192.168.56.2" -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

echo "SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
SSLHonorCipherOrder On

Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff

SSLCompression off
SSLUseStapling on
SSLStaplingCache "shmcb:logs/stapling-cache(150000)"

SSLSessionTickets Off
" >> /etc/apache2/conf-available/ssl-params.conf

sudo scp -P 2222 default-ssl.conf nsance@192.168.56.2:/etc/apache2/sites-available/

sudo rm -rf /etc/apache2/sites-available/000-default.conf
sudo echo "<VirtualHost *:80>

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html

	Redirect "/" "https://192.168.99.100/"

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
" >> /etc/apache2/sites-available/000-default.conf

sudo a2enmod ssl
sudo a2enmod headers
sudo a2ensite default-ssl
sudo a2enconf ssl-params
systemctl reload apache2
