# Install influxdb:

# configure the package sources:
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

# install influxdb:
apt-get update && sudo apt-get install influxdb

# start influxdb:
service influxdb start

############
# Grafana:

wget https://grafanarel.s3.amazonaws.com/builds/grafana_4.1.1-1484211277_amd64.deb
apt-get install -y adduser libfontconfig
dpkg -i grafana_4.1.1-1484211277_amd64.deb

service grafana-server start

# To have launchd start grafana now and restart at login:
#  brew services start grafana
  
#Or, if you don't want/need a background service you can just run:
#  grafana-server --config=/usr/local/etc/grafana/grafana.ini --homepath /usr/local/share/grafana cfg:default.paths.logs=/usr/local/var/log/grafana cfg:default.paths.data=/usr/local/var/lib/grafana cfg:default.paths.plugins=/usr/local/var/lib/grafana/plugins