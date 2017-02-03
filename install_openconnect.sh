#install basics:
sudo update && sudo apt-get install build-essential git vim python-dev



#get vpnc-script and install:
wget http://git.infradead.org/users/dwmw2/vpnc-scripts.git/blob_plain/HEAD:/vpnc-script
sudo mkdir /etc/vpnc/ && sudo mv vpnc-script /etc/vpnc/ && sudo chmod 755 /etc/vpnc/vpnc-script

##############################
# pre-requesits for openconnect:
# openssl
git clone https://github.com/openssl/openssl.git && cd openssl/ && ./config && make && sudo make install

# pkg-config:
wget https://pkg-config.freedesktop.org/releases/pkg-config-0.29.1.tar.gz && tar -zxf pkg-config-0.29.1.tar.gz && rm pkg-config-0.29.1.tar.gz && cd pkg-config-0.29.1
./configure --with-internal-glib && make && sudo make install

# libxml2:
wget ftp://xmlsoft.org/libxml2/libxml2-git-snapshot.tar.gz && tar -zxf libxml2-git-snapshot.tar.gz && rm libxml2-git-snapshot.tar.gz && cd libxml2-2.9.4/
./configure && make && sudo make install

# zlib:
wget http://zlib.net/zlib-1.2.8.tar.gz && tar -zxf zlib-1.2.8.tar.gz  && rm zlib-1.2.8.tar.gz  && cd zlib-1.2.8
./configure && make && sudo make install

##############################

# Install openconnect:
wget ftp://ftp.infradead.org/pub/openconnect/openconnect-7.07.tar.gz && tar -zxf openconnect-7.07.tar.gz && rm openconnect-7.07.tar.gz
cd openconnect-7.07
./configure --disable-nls && make && sudo make install

Add this to /etc/ld.so.conf
include /usr/local/lib/*
sudo ldconfig

# install openvpn
sudo apt-get install openvpn