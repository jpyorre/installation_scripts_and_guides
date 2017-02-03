sudo apt-get update && sudo apt-get install -y xdg-utils ImageMagick xvfb
wget --no-check-certificate https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py
sudo python linux-installer.py

# make library add folder:
mkdir -p ~/calibre/to-add/

# Add library:
#xvfb-run calibredb add -r ~/Books --library-path ~/calibre

# run server:
calibre-server --with-library ~/calibre --p 8000 --username 'username' --password 'supersecretpassword'


cat > /etc/init/calibre-server.conf<<EOF
description "Calibre (ebook manager) content server"

start on runlevel [2345]
stop on runlevel [^2345]

respawn

env USER='username'
env PASSWORD='supersecretpassword'
env LIBRARY_PATH='/home/user/calibre'
env MAX_COVER='300x400'
env PORT='8000'

script
    exec /usr/bin/calibre-server --with-library $LIBRARY_PATH --auto-reload \
                                 --max-cover $MAX_COVER --port $PORT \
                                 --username $USER --password $PASSWORD
end script
EOF


(crontab -l; echo "*/10 * * * * xvfb-run calibredb add /home/user/calibre/to-add/ -r --with-library /home/user/calibre && rm /home/user/calibre/to-add/*" ) | crontab -u username -