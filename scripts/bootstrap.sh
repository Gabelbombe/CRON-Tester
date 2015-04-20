#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

# Update Apt
# --------------------
apt-get update


# Install Apache & PHP (v5.4)
# --------------------
apt-get install -y apache2
apt-get install -y php5
apt-get install -y libapache2-mod-php5
apt-get install -y php5-mysqlnd php5-curl php5-xdebug php5-gd php-pear php5-imap php5-mcrypt php5-sqlite php5-tidy php5-xmlrpc php5-xsl php-soap

php5enmod mcrypt

# Install GIT
# --------------------
apt-get install -y git

# Delete default apache web dir and symlink mounted vagrant dir from host machine
# --------------------
rm -rf /var/www/html /vagrant/httpdocs

mkdir -p /vagrant/httpdocs

ln -fs /vagrant/httpdocs /var/www/html

# Replace contents of default Apache vhost
# --------------------
VHOST=$(cat <<EOF
Listen 8080
<VirtualHost *:80>
  DocumentRoot "/var/www/html"
  ServerName localhost
  <Directory "/var/www/html">
    AllowOverride All
  </Directory>
</VirtualHost>
<VirtualHost *:8080>
  DocumentRoot "/var/www/html"
  ServerName localhost
  <Directory "/var/www/html">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)

echo "$VHOST" > /etc/apache2/sites-enabled/000-default.conf
a2enmod rewrite
service apache2 restart


# MariaDB
# --------------------
# Ignore the post install questions
export DEBIAN_FRONTEND=noninteractive

apt-get -q -y install mysql-server-5.5

sed -ie 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/my.cnf
service mysql restart


# Create a God mode user
# --------------------
mysql -u root -e "CREATE USER 'god'@'localhost'"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'god'@'localhost' WITH GRANT OPTION"

mysql -u root -e "CREATE USER 'god'@'%'"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'god'@'%' WITH GRANT OPTION"

mysql -u root -e "FLUSH PRIVILEGES"


# Load PHP Info
# --------------------
echo '<?php phpinfo();' > /vagrant/httpdocs/index.php


# Clone in CRON dump
# --------------------
curl -sSL https://raw.githubusercontent.com/ehime/Bash-Tools/master/OS/dump-cronjobs.sh -o crondump
chmod +x crondump

mv crondump /bin
