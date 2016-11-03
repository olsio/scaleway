#!/bin/sh
MAIN_DOMAIN="$1"
ALL_DOMAIN_ALIASES="$2"
SMTP_USER="$3"
SMTP_PASSWORD="$4"
EMAIL="$5"

if [ -z "$MAIN_DOMAIN" ]; then
    echo "MAIN_DOMAIN not set"
    exit 1
fi

if [ -z "$ALL_DOMAIN_ALIASES" ]; then
    echo "ALL_DOMAIN_ALIASES not set"
    exit 1
fi

if [ -z "$SMTP_USER" ]; then
    echo "SMTP_USER not set"
    exit 1
fi

if [ -z "$SMTP_PASSWORD" ]; then
    echo "SMTP_PASSWORD not set"
    exit 1
fi

if [ -z "$EMAIL" ]; then
    echo "EMAIL not set"
    exit 1
fi

##############################################################
# Installing base pagages
##############################################################
export DEBIAN_FRONTEND=noninteractive
apt-key adv --fetch-keys http://dl.yarnpkg.com/debian/pubkey.gpg
echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt-get -q update && \
    apt-get -y -q upgrade && \
    apt-get install -y -q curl \
        iptables \
        iptables-persistent \
        nginx \
        openvpn \
        supervisor \
        stunnel4 \
        uuid \
        zip \
        uuid \
        git \
        mc \
        wget \
        bc \
        apache2-utils \
        w3m \
        ssmtp \
        build-essential \
        yarn \
        vim && \
    apt-get clean

##############################################################
# Installing Node
##############################################################
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get install -y -q nodejs

##############################################################
# Clean default files
##############################################################
rm -f /etc/nginx/sites-enabled/*

##############################################################
# Download custom scripts and configurations
##############################################################
rm -rf ./scaleway
git clone https://github.com/olsio/scaleway.git scaleway

##############################################################
# Patch files
##############################################################
find ./scaleway/ghost -type f -exec sed -i "s/MAIN_DOMAIN/$MAIN_DOMAIN/g" {} +
find ./scaleway/ghost -type f -exec sed -i "s/ALL_DOMAIN_ALIASES/$ALL_DOMAIN_ALIASES/g" {} +
find ./scaleway/ghost -type f -exec sed -i "s/SMTP_USER/$SMTP_USER/g" {} +
find ./scaleway/ghost -type f -exec sed -i "s/SMTP_PASSWORD/$SMTP_PASSWORD/g" {} +
find ./scaleway/ghost -type f -exec sed -i "s/EMAIL/$EMAIL/g" {} +
find ./scaleway/ghost -type f -exec sed -i "s/HOSTNAME/$HOSTNAME/g" {} +

##############################################################
# Copy to destinations
##############################################################
cp -R ./scaleway/ghost/* /

##############################################################
# Install ghost
##############################################################
wget -qO ghost.zip https://ghost.org/zip/ghost-latest.zip && \
    rm -rf /var/www && \
    unzip ghost.zip -d /var/www/ && \
    rm -f ghost.zip && \
    cp -R ./scaleway/ghost/* / && \
    cd /var/www && npm install nodemailer-mailgunapi-transport --save && \
    npm install --production && \
    cd -
useradd ghost && chown -R ghost:ghost /var/www

##############################################################
# Start supervisord on reboot
##############################################################
update-rc.d supervisor enable
service supervisor stop
service supervisor start

##############################################################
# Create lets encrypt certificates
##############################################################
ln -sf /etc/nginx/sites-available/cert-only /etc/nginx/sites-enabled/cert-only
/usr/sbin/service nginx restart
git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
config_file="/usr/local/etc/le-renew-webroot.ini"
tmp_dir="/tmp/letsencrypt-auto"
le_path='/opt/letsencrypt'
mkdir -p $tmp_dir
$le_path/letsencrypt-auto certonly -a webroot --agree-tos --config $config_file
(crontab -l 2>/dev/null; echo "30 2 * * * /usr/local/sbin/le-renew-webroot >> /var/log/le-renewal.log") | crontab -

password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
echo $password | htpasswd -csi /etc/nginx/.htpasswd ghost
echo "$password" > /root/ghost.password

##############################################################
# Enable SSL nginx site
##############################################################
rm -f /etc/nginx/sites-enabled/*
ln -sf /etc/nginx/sites-available/site /etc/nginx/sites-enabled/site
/usr/sbin/service nginx reload

##############################################################
# Replace default dhparam with fresh primes
##############################################################
nohup sh -c 'openssl dhparam -out /tmp/dhparam.pem 4096; mv /tmp/dhparam.pem /etc/letsencrypt/dh/dhparam.pem; /usr/sbin/service nginx reload' >/dev/null 2>&1 &

##############################################################
# Pring Ghost admin password
##############################################################
echo "Ghost Password"
cat /root/ghost.password