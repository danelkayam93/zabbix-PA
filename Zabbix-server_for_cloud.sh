#!/bin/bash

####Script bash for download zabbix server#####
#Variable
#IP=$(hostname -I)

ip_publique=$(wget -q -O - checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//')
#Step 1:  Install LAMP
echo -e "\e[1;36m ######################STEP 1############################# \e[0m"

sudo apt update

sudo apt install nginx -y
sudo apt install ufw -y

sudo ufw allow 'Nginx HTTP'

sudo apt install mysql-server -y

sudo apt install php-fpm php-mysql -y

# Step 2 : Install Zabbix package

echo -e "\e[1;36m ######################STEP 2############################# \e[0m"

wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb
sudo dpkg -i zabbix-release_5.0-1+focal_all.deb
sudo apt update -y
sudo apt install zabbix-server-mysql zabbix-frontend-php -y
sudo apt install zabbix-agent -y

# Step 3 : Configur database Zabbix

echo -e "\e[1;36m ######################STEP 3############################# \e[0m"

sudo mysql -u root -e "create database zabbix character set utf8 collate utf8_bin;"
sudo mysql -u root -e "create user zabbix@localhost identified by 'azerty';"
sudo mysql -u root -e "grant all privileges on zabbix.* to zabbix@localhost;"


sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix --password=azerty --force

sudo sed -i 's/# DBPassword=/DBPassword=azerty/' /etc/zabbix/zabbix_server.conf

# Step 4 : Configure Nginx for Zabbix
echo -e "\e[1;36m ######################STEP 4############################# \e[0m"

sudo apt install zabbix-nginx-conf -y

sudo sed -i "s/#        listen          80/        listen          80/" /etc/zabbix/nginx.conf
sudo sed -i "s/#        server_name     example.com;/        server_name     ${ip_publique};/" /etc/zabbix/nginx.conf
sudo nginx -s reload

# Step 5 Configure PHP for Zabbix
echo -e "\e[1;36m ######################STEP 5############################# \e[0m"

sudo sed -i "s/; php_value\[date.timezone\] = Europe\/Riga/php_value\[date.timezone\] = Europe\/Paris/" /etc/zabbix/php-fpm.conf
sudo systemctl restart php7.4-fpm.service
sudo systemctl start zabbix-server
sudo systemctl enable zabbix-server

echo -e "\e[1;36m ######################Zabbix Pret sur l'adresse ${ip_publique}############################# \e[0m"
