if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root or with sudo privileges."
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "This script requires exactly one argument."
    exit 1
fi

echo "Creating directory /var/www/$1..."
mkdir "/var/www/$1"
sudo chown jx:apache /var/www/$1

echo "Adding test page to /var/www/$1..."
echo "<?php echo \"$1\n\";" >> /var/www/$1/index.php
sudo chown jx:apache /var/www/$1/index.php

echo "Adding $1.local to /etc/hosts"
sudo echo "127.0.0.1 $1.local" >> /etc/hosts

echo "Adding $1 section to /etc/httpd/conf.d/vhost.conf"
sudo echo "
<VirtualHost *:80>
	ServerName $1.local
	DocumentRoot /var/www/$1
	ErrorLog /var/log/httpd/$1_error.log
	CustomLog /var/log/httpd/$1_access.log combined
</VirtualHost>
" >> /etc/httpd/conf.d/vhost.conf

echo "Restarting httpd..."
sudo systemctl restart httpd

echo "Test site..."
curl $1.local
