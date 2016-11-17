echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list

apt-get update
apt-get -y install emacs-nox git build-essential automake libgd2-noxpm-dev libjpeg-dev libpng-dev nginx

adduser danbooru

mkdir -p /var/run/iqdbs
mkdir -p /var/log/iqdbs
chown -R danbooru:danbooru /var/run/iqdbs
chown -R danbooru:danbooru /var/log/iqdbs

# download iqdb
# build iqdb
# install iqdb
# install iqdb init script
# start iqdb

# set up lets encrypt
mkdir -p /var/www/iqdbs
chown -R danbooru:danbooru /var/www/iqdbs
apt-get -y install certbot -t jessie-backports
apt-get -y install python-certbot-nginx -t jessie-backports
certbot --nginx

# install rbenv
# install ruby 2.3.1