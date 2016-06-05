#!/bin/sh



##############################################################
# Installing base pagages
##############################################################
export DEBIAN_FRONTEND=noninteractive
apt-get -q update && \
    apt-get -y -q upgrade && \
    apt-get install -y -q curl \
        iptables \
        iptables-persistent \
        openvpn \
        nginx \
        supervisor \
        zip \
        uuid \
        git \
        mc \
        wget \
        bc \
        apache2-utils \
        vim && \
    apt-get clean


##############################################################
# Clean default files
##############################################################
rm -f /etc/nginx/sites-available/*
rm -f /etc/nginx/sites-enabled/*


##############################################################
# Download and copy custom scripts and configurations
##############################################################
rm -rf ./scaleway
git clone https://github.com/olsio/scaleway.git scaleway
cp -R ./scaleway/overlay/* /


##############################################################
# Install node
##############################################################
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.1/install.sh | bash
source .bashrc
nvm install v0.10.40
n=$(which node);n=${n%/bin/node}; chmod -R 755 $n/bin/*; sudo cp -r $n/{bin,lib,share} /usr/local


##############################################################
# Install ghost
##############################################################
wget -qO ghost.zip https://ghost.org/zip/ghost-latest.zip && \
    rm -rf /var/www && \
    unzip ghost.zip -d /var/www/ && \
    rm -f ghost.zip && \
    cd /var/www && npm install --production && \
    cd -
useradd ghost && chown -R ghost:ghost /var/www


##############################################################
# Start supervisord on reboot
##############################################################
update-rc.d supervisor enable
supervisor stop
supervisor start

##############################################################
# Create lets encrypt certificates
##############################################################
ln -sf /etc/nginx/sites-available/cert-only /etc/nginx/sites-enabled/cert-only
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
config_file="/usr/local/etc/le-renew-webroot.ini"
tmp_dir="/tmp/letsencrypt-auto"
le_path='/opt/letsencrypt'
$le_path/letsencrypt-auto certonly -a webroot --agree-tos --config $config_file
(crontab -l 2>/dev/null; echo "30 2 * * * /usr/local/sbin/le-renew-webroot >> /var/log/le-renewal.log") | crontab -

uuidgen=$(uuidgen)
echo $uuidgen | htpasswd -cBi /etc/nginx/.htpasswd ols

##############################################################
# Enable SSL nginx site
##############################################################
rm -f /etc/nginx/sites-enabled/*
ln -sf /etc/nginx/sites-available/olsio /etc/nginx/sites-enabled/olsio
/usr/sbin/service nginx reload

##############################################################
# Replace default dhparam with fresh primes
##############################################################
(openssl dhparam -out /tmp/dhparam.pem 4096; mv /tmp/dhparam.pem /etc/letsencrypt/dh/dhparam.pem; /usr/sbin/service nginx reload) &
