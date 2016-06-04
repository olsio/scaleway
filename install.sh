#!/bin/sh

export DEBIAN_FRONTEND=noninteractive
apt-get -q update
apt-get -y -q upgrade
apt-get install -y -q curl iptables iptables-persistent openvpn nginx supervisor zip uuid git mc wget vim
apt-get clean

rm -f /etc/nginx/sites-available/*
rm -f /etc/nginx/sites-enabled/*

rm -rf ./scaleway
git clone https://github.com/olsio/scaleway.git scaleway
cp -R ./scaleway/overlay/etc/ /etc/
cp -R ./scaleway/overlay/usr/local/ /usr/local/

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.1/install.sh | bash
source .bashrc

nvm install v0.10.40

wget -qO ghost.zip https://ghost.org/zip/ghost-latest.zip && \
    rm -rf /var/www && \
    unzip ghost.zip -d /var/www/ && \
    rm -f ghost.zip && \
    cd /var/www && npm install --production


useradd ghost && chown -R ghost:ghost /var/www

ln -sf /etc/nginx/sites-available/olsio /etc/nginx/sites-enabled/olsio
