#!/bin/bash
# Asking for adding user
read -p "Add user ? (y/n) : " booluser
if [ $booluser = "y" ]
then
    read -p "Type the user name : " charuser
    apt-get install -y adduser
    adduser $charuser
    read -p "Add another user ? (y/n) : " booluser
    while [ $booluser = "y" ]
    do
	      read -p "Type the user name : " charuser
	      adduser $charuser
	      read -p "Add another user ? (y/n) : " booluser
    done
fi

# Asking for installations
read -p "Install FTP server ? (y/n) : " ftpserver
read -p "Install webserver (Apache2 + PHP + MySQL) ? (y/n) : " webserver
read -p "Install Laravel ? (y/n) : " laravel

# Update system
apt-get -y update && -y apt-get upgrade && apt-get dist-upgrade -y

# Install utils
apt-get install -y emacs python-software-properties gzip adduser curl zip unzip screen

# Install ftpserver
if [ $ftpserver = "y" ]
then
    apt-get install -y proftpd
    service proftpd restart
fi

# Install webserver
if [ $webserver = "y" ]
then
    echo "deb http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list
    wget https://www.dotdeb.org/dotdeb.gpg && apt-key add dotdeb.gpg
    apt-get update
    apt-get install -y apache2 mysql-server php7.0 php7.0-fpm libapache2-mod-php7.0 php7.0-gd php7.0-mysql php7.0-bz2 php7.0-json php7.0-curl php7.0-mbstring php7.0-dom
    service php7.0-fpm restart
    service apache2 restart
fi

# Install Laravel
if [ $laravel = "y" ]
then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
    cd /var/www
    git clone https://github.com/laravel/laravel.git
    cd /var/www/laravel
    composer install
    chown -R www-data.www-data /var/www/laravel
    chmod -R 755 /var/www/laravel
    chmod -R 777 /var/www/laravel/storage
    mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.old
    rm -f /etc/apache2/sites-enabled/*
    cp /root/initvps/laravel.conf /etc/apache2/sites-available/laravel.conf
    cd /etc/apache2/sites-enabled
    ln -s ../sites-available/laravel.conf
    service apache2 reload
    cd /var/www/laravel
    cp -p .env.example .env
    php artisan key:generate
fi

# Clear terminal and display end of work
clear
printf "


Work ended. Enjoy! You can find other stuff in FlorianGoMore GitHub.

You can find informations bellow :
IP address : $(ifconfig | perl -nle 's/dr:(\S+)/print $1/e' | head -n 1)
PHP version : $(php -v | head -n 1)

"
