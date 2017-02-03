# Install dependencies:
apt-get update
apt-get -y install build-essential ca-certificates curl git vim dh-autoreconf python python-dev ssdeep subversion zlib1g-dev autoconf make libssl-dev libgraphviz-dev graphviz graphviz-dev gyp libboost-dev libboost-python-dev libboost-python1.55.0 libboost-system1.55.0 libboost-system-dev libboost-thread-dev libboost-thread1.55.0 libemu-dev libemu2 libffi-dev libfuzzy-dev libpcre3 libpcre3-dev librabbitmq1 libtool libxml2-dev libxslt1-dev pkg-config

# Get some things you need (pyv8 and v8, whatever the hell those are):
cd /opt/ && git clone https://github.com/aikinci/thug.git && cp thug/pyv8_r586.tar.bz2 /opt/  && cp thug/v8_r19632.tar.bz2 /opt/ 

# install pip:
curl -O -k https://bootstrap.pypa.io/get-pip.py && python /opt/get-pip.py
echo '--install-option="--include-path=/usr/include/graphviz" --install-option="--library-path=/usr/lib/graphviz/"' > /opt/requirements.txt

# Make a requirements file:
curl https://raw.githubusercontent.com/buffer/thug/master/src/requirements.txt >> /opt/requirements.txt

# Install some more things via pip, including requirements:
pip install cryptography future markerlib yara pyopenssl ndg-httpsclient pyasn1
pip install -r /opt/requirements.txt

# Get this stuff because reasons:
git clone https://github.com/erocarrera/pefile.git && cd /opt/pefile/ && python setup.py build && python setup.py install

# Make install yara:
cd /opt && curl -LO https://github.com/plusvic/yara/archive/v3.4.0.tar.gz && tar xfz v3.4.0.tar.gz && cd /opt/yara-3.4.0/ && ./bootstrap.sh && ./configure && make && make install

# Move things around:
cd /opt/ && mv thug thugsupportfiles
cd /opt/ && git clone https://github.com/buffer/thug.git

# These changes are disabled, but here in case you want to enable them:
# disable mongodb sed -i '/^[[:blank:]]*[mongodb]$/{n;s/True/False/g;}' /opt/thug/src/Logging/logging.conf && 
# disable elasticsearch sed -i '/^[[:blank:]]*[elasticsearch]$/{n;s/True/False/g;}' /opt/thug/src/Logging/logging.conf && 
# disable hpfeeds sed -i '/^[[:blank:]]*[hpfeeds]$/{n;s/True/False/g;}' /opt/thug/src/Logging/logging.conf && 

# PyV8 and V8 patching and installation (still no idea what these are, but you need them):
bunzip2 pyv8_r586.tar.bz2 && bunzip2 v8_r19632.tar.bz2 && tar -xf pyv8_r586.tar && tar -xf v8_r19632.tar
patch -d /opt/ -p0 <  /opt/thug/patches/PyV8-patch1.diff && patch -d /opt/v8/ -p1 < /opt/thug/patches/V8-patch1.diff
cd /opt/pyv8/ && python setup.py build && python setup.py install

# Yara is being a pain, so pip remove it and then install it with python:
pip uninstall yara -y
cd /opt/yara-3.4.0/yara-python && python setup.py build && python setup.py install

# Do this to make the yara go:
echo "/usr/local/lib" >> /etc/ld.so.conf && ldconfig

# Actually install thug:
cd /opt/thug/src/ && python setup.py build && python setup.py install