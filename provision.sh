#!/usr/bin/env bash
#
#VARIABLES
#
sitename='<CHANGE_ME>'
wpuser='admin'
password='admin'
email='test@example.com'
dbname='wordpress'
wpversion='5.0.3'

#
#Installation
#
echo "---------------------"
echo "setting up Apache"
echo "---------------------"
#Installing and setting up Apache
apt-get update
apt-get install -y apache2

#add ServerName to end of apache2.conf
echo "ServerName 192.168.33.10" >> /etc/apache2/apache2.conf
#open firewall
sudo ufw allow in "Apache Full"
# Make Apache look for index.php files first
sed -i 's/DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/g' /etc/apache2/mods-enabled/dir.conf
#start installing php and mysql.
echo "---------------------"
echo "Install PHP and MySQL"
echo "---------------------"
sudo apt-get install -y php7.0 php7.0-cli libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-mbstring php7.0-gd php7.0-xml php7.0-xmlrpc php7.0-intl php7.0-soap php7.0-zip
sudo apt-get install -y curl
sudo apt-get install -y unzip git-core subversion
#setup mysql username and password
echo mysql-server mysql-server/root_password password root | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password root | sudo debconf-set-selections
sudo apt-get install -y mysql-server
echo "---------------------"
echo "Install WP-CLI"
echo "---------------------"
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
echo "---------------------"
echo "Installing WordPress"
echo "---------------------"
cd /vagrant/wordpress
# download the WordPress core files
# wp core download
if [ -z "$wpversion" ]
then
sudo -u www-data -- wp core download
else
sudo -u www-data -- wp core download --version=$wpversion
fi

# create the wp-config file
sudo -u www-data -- wp core config --dbname=$dbname --dbuser=root --dbpass=root

# create database, and install WordPress
sudo -u www-data -- wp db create
sudo -u www-data -- wp core install --url="http://$sitename/" --title="$sitename" --admin_user="$wpuser" --admin_password="$password" --admin_email="$email" --skip-email

# Install All-In-One-WP-Migration plugin
sudo -u www-data -- wp plugin install all-in-one-wp-migration --activate

# Update php.ini file
sed -i 's/post_max_size = 8M/post_max_size = 2048M/g' /etc/php/7.0/apache2/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 2048M/g' /etc/php/7.0/apache2/php.ini

#enable mod_rewrite and restart apache
sudo a2enmod rewrite
sudo service apache2 restart
echo "---------------------"
echo "Installation is complete. Your username/password is listed below."
echo ""
echo "Username: $wpuser"
echo "Password: $password"
echo ""
echo "---------------------"

