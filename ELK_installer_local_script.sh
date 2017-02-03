#! /bin/bash

logstash="https://download.elastic.co/logstash/logstash/packages/debian/logstash_2.3.2-1_all.deb"
elasticsearch="https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.3.3/elasticsearch-2.3.3.deb"

# Used to get the architecture for the installation of ElasticSearch and Kibana:
getarchitecture(){
        architecture=0
        echo "Are you running on 32 bit or 64 bit architecture? Enter 32 or 64"
        read architecture
        if [ $architecture -eq 32 ]
                then es_architecture="export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386/" && kibana="https://download.elastic.co/kibana/kibana/kibana-4.5.1-linux-x86.tar.gz"
        elif [ $architecture -eq 64 ]
                then es_architecture="export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/" && kibana="https://download.elastic.co/kibana/kibana/kibana-4.5.1-linux-x64.tar.gz"
        else
                getarchitecture;
        fi
}

getelasticsearchname(){
      
        echo "What do you want to call the Elasticsearch Cluster? <enter some sort of unique name>"
        read es_cluster
}

getarchitecture;
getelasticsearchname;

# Stuff we need for various parts of this installation:
apt-get update && apt-get install build-essential libffi-dev apache2 stunnel4 supervisor openjdk-7-jdk curl libgeoip-dev git apache2-utils -y

####### LOGSTASH CONFIG #######

cd /usr/local/src && wget $logstash && dpkg -i logstash*


# Logstash config file:
cat > /etc/logstash/conf.d/server.conf<<EOF
input {
    file {
        type => "giveitaname"
        path => "/path/to/log/file.log"
        start_position => "beginning"
        }
}

filter {

}

output {
  elasticsearch {
                cluster => "temporaryclustername"
                bind_host => "127.0.0.1"
                }
}
EOF


sed -i "s/temporaryclustername/$es_cluster/g" /etc/elasticsearch/elasticsearch.yml /etc/logstash/conf.d/server.conf 


####### END LOGSTASH CONFIG #######

####### ELASTICSEARCH CONFIG #######
# For 32 bit: export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386/
# For 64 bit: export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/
# handled in the beginning with the getarchitecture function

# Install elasticsearch:
cd /usr/local/src && wget $elasticsearch && dpkg -i elasticsearch* && update-rc.d elasticsearch defaults 95 10

# This first sed command uses double quotes because you have to use double quotes to use a bash variable
sed -i "s/# cluster.name: my-application/cluster.name: $es_cluster/g" /etc/elasticsearch/elasticsearch.yml
sed -i 's/#node.name: "Franz Kafka"/node.name: "localELKinstance"/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/#network.host: 192.168.0.1/network.host: localhost/g' /etc/elasticsearch/elasticsearch.yml
####### END ELASTICSEARCH CONFIG #######


####### KIBANA CONFIG #######
# Kibana and apache
# handled in the beginning with the getarchitecture function

cd /var/www/ && wget $kibana && tar -zxf kibana* && rm *.gz && mv kibana* kibana && chown -R www-data:www-data kibana

# limit access to kibana to local connections only. This is so we can proxy through apache and use https
# The host to bind the server to.
sed -i 's/host: "0.0.0.0"/host: "127.0.0.1"/g' /var/www/kibana/config/kibana.yml

# DEPRECATED Set kibana to be able to read files owned by root:
#usermod -a -G adm logstash

# Setup kibana to start at boot
cat > /opt/kibana_start.sh <<EOF
#!/bin/sh
sh /var/www/kibana/bin/kibana
EOF

chmod 755 /opt/kibana_start.sh

cat > /etc/supervisor/conf.d/kibana.conf <<EOF
[program:kibana]
command=/opt/kibana_start.sh
directory=/var/www/kibana
stdout_logfile=/opt/kibana.out
stderr_logfile=/opt/kibana.err
autostart=true
autorestart=true
redirect_stderr=true
stopsignal=QUIT
EOF

####### END KIBANA CONFIG #######


####### SSL CONFIG #######
# generate ssl keys:
# Generate and copy to /usr/local/certs/sslcerts/
mkdir /usr/local/certs/ && mkdir /usr/local/certs/sslcerts/ && cd /usr/local/certs/sslcerts/

# Create server key and certificate signing request:
openssl req -new -out csr.key -passout pass:password -subj "/C=US/ST=CA/L=ELK/O=ELK/OU=ELK/CN=ELK CA/emailAddress=nonei@tld.com"

# Remove the Passphrase
openssl rsa -in privkey.pem -passin pass:password -out server.key

# Sign certificate:
openssl x509 -req -days 3600 -in csr.key -signkey server.key -out server.crt
####### SSL CONFIG #######


####### APACHE CONFIG #######

# You have to run htpasswd to set up a user who can access the kibana interface:

#sudo htpasswd -c /opt/.htpasswd-private username
mkdir /var/www/kibana && chown www-data:www-data /var/www/kibana

rm /etc/apache2/sites-enabled/000-default*
cat > /etc/apache2/sites-enabled/kibana.conf<<EOF
<VirtualHost *:443>
    ProxyPreserveHost On
    ProxyPass / http://localhost:5601/
    <Location />
        Order allow,deny
        Allow from all
   </Location>
     SSLEngine on
     SSLOptions +StrictRequire
     SSLCertificateFile /usr/local/certs/sslcerts/server.crt
     SSLCertificateKeyFile /usr/local/certs/sslcerts/server.key
</VirtualHost>
EOF


a2enmod proxy_http && a2enmod ssl

####### END APACHE CONFIG #######


####### START SERVICES #######
supervisorctl update
service elasticsearch restart
service apache2 restart

echo "Installation complete. Kibana can be found at https://localhost"
echo "You still have to modify the logstash config file /etc/logstash/conf.d/server.conf to read something, then run: service logstash start"
