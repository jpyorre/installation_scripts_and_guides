sudo apt-get update && sudo apt-get install vim apache2 mysql-server php5-mysql php5 php5-gd libapache2-mod-php5 php5-mcrypt curl -y

# setup tools:
cd /usr/local/src && curl -O -k https://bootstrap.pypa.io/get-pip.py && python /usr/local/src/get-pip.py


# create MySQL database directory structure:
sudo mysql_install_db

# run a security script that will remove some dangerous defaults and lock down access to our database system:
sudo mysql_secure_installation

mkdir /var/www/absentfaith

Make db, install wordpress, set it up:
create database wordpress;
GRANT ALL PRIVILEGES ON wordpress.* to 'wordpress'@'localhost' IDENTIFIED BY 'supersecretpassword';
flush privileges;
exit;


Add the site information to /etc/apache2/sites-available/000-default.conf
a2enmod 000-default.conf
service apache2 reload

# certbot, for letsencrypt certificates:
cd /usr/local/src && git clone https://github.com/certbot/certbot && cd certbot && ./certbot-auto