apt-get update && apt-get install git-core binutils-dev libldns1 libldns-dev libpcap-dev autoconf libdate-simple-perl build-essential libtool libdatetime-perl mysql-server mysql-client apache2 php5 php5-mysql php5-gd libmysqlclient-dev ruby libapache2-mod-passenger libcurl4-openssl-dev apache2-threaded-dev libapr1-dev libaprutil1-dev ruby-dev -y

cd /usr/local/src && git clone https://github.com/phunold/pdns-ui && git clone https://github.com/gamelinux/passivedns

sudo mv pdns-ui/ /var/www/

cd /usr/local/src/passivedns

autoreconf --install
./configure
make
make install # if you want to install it




MySQL DB:
CREATE DATABASE pdns;
GRANT USAGE ON *.* TO 'pdns'@'localhost' IDENTIFIED BY 'supersecretpassword';
GRANT SELECT,CREATE,INSERT,UPDATE ON pdns.* TO 'pdns'@'localhost';
flush privileges;
exit;

# Starting passivedns, if you're ready:
./passivedns -i eth1 -l /var/log/passivedns.log


pdns-ui:
#cd /var/www/ && git clone https://github.com/phunold/pdns-ui.git
cd /var/www/pdns-ui
cp config/database.yml.example config/database.yml
cp config/app.yml.example config/app.yml

vim database.yml and change the db password to what was specified in the sql command

# maybe:
chown -R www-data:www-data /var/www/pdns-ui

cd /var/www/pdns-ui
gem install bundler --no-ri --no-rdoc
gem install passenger --no-ri --no-rdoc
passenger-install-apache2-module

# After running this, the text to put into the apache config will be displayed. Copy and paste that into /etc/apache2/apache.conf


vim /etc/apache2/sites-enabled/pdns:
root@ubuntu:/etc/apache2# vim sites-enabled/pdns 

<VirtualHost *:80>
    ServerName SERVERNAMEORIPHERE
    DocumentRoot /var/www/pdns-ui/public
    #PassengerRuby /usr/bin/ruby1.9.1
    <Directory /var/www/pdns-ui/public>
        Allow from all
        Options -MultiViews
    </Directory>
</VirtualHost>            


# in /var/www/pdns-ui/, run the following (not as root)
bundle install

------------------
Getting archived data into the db:
~/passivedns/tools/pdns2db.pl --file /var/log/passivedns.log


perl ~/passivedns/tools/pdns2db.pl --file /var/log/passivedns.log