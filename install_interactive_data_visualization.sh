# From http://adilmoujahid.com/posts/2015/01/interactive-data-visualization-d3-dc-python-mongodb/


apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 # for mongodb
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list  # for mongodb
apt-get update
apt-get install -y mongodb-org vim apache2 curl

# install pip:
cd /usr/local/src && wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py

# install pymongo
python -m pip install pymongo

# install virtualenv:
pip install virtualenv

# set up virtualenv for a working directory:
mkdir myproject
cd myproject
virtualenv venv

# activate:
. venv/bin/activate
# install flask in venv:
pip install Flask