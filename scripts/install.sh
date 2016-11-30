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
RUBY_VERSION=2.3.1
cd /
sudo -u danbooru git clone git://github.com/sstephenson/rbenv.git ~danbooru/.rbenv
sudo -u danbooru touch ~danbooru/.bash_profile
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~danbooru/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~danbooru/.bash_profile
sudo -u danbooru mkdir -p ~danbooru/.rbenv/plugins
sudo -u danbooru git clone git://github.com/sstephenson/ruby-build.git ~danbooru/.rbenv/plugins/ruby-build
sudo -u danbooru bash -l -c "rbenv install $RUBY_VERSION"
sudo -u danbooru bash -l -c "rbenv global $RUBY_VERSION"
