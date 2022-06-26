#!/bin/bash

####Script bash for download and install zabbix server#####
#Variable
IP=$(hostname -I)

#Step 1:  Install LAMP
echo -e "\e[1;36m ######################STEP 1############################# \e[0m"

apt update

apt install nginx -y
apt install ufw -y

ufw allow 'Nginx HTTP'

apt install mysql-server -y

apt install php-fpm php-mysql -y

# Step 2 : Install Zabbix package

echo -e "\e[1;36m ######################STEP 2############################# \e[0m"

wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb
dpkg -i zabbix-release_5.0-1+focal_all.deb
apt update -y
apt install zabbix-server-mysql zabbix-frontend-php -y
apt install zabbix-agent -y

# Step 3 : Configur database Zabbix

echo -e "\e[1;36m ######################STEP 3############################# \e[0m"

mysql -u root -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -u root -e "create user zabbix@localhost identified by 'azerty';"
mysql -u root -e "grant all privileges on zabbix.* to zabbix@localhost;"


zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix --password=azerty --force

sed -i 's/# DBPassword=/DBPassword=azerty/' /etc/zabbix/zabbix_server.conf

# Step 4 : Configure Nginx for Zabbix
echo -e "\e[1;36m ######################STEP 4############################# \e[0m"

apt install zabbix-nginx-conf -y

sed -i "s/#        listen          80/        listen          80/" /etc/zabbix/nginx.conf
sed -i "s/#        server_name     example.com;/        server_name     ${IP};/" /etc/zabbix/nginx.conf
nginx -s reload

# Step 5 Configure PHP for Zabbix
echo -e "\e[1;36m ######################STEP 5############################# \e[0m"

sed -i "s/; php_value\[date.timezone\] = Europe\/Riga/php_value\[date.timezone\] = Europe\/Paris/" /etc/zabbix/php-fpm.conf
systemctl restart php7.4-fpm.service
systemctl start zabbix-server
systemctl enable zabbix-server

echo -e "\e[1;36m ######################Zabbix Pret sur l'adresse ${IP}############################# \e[0m"apt update
