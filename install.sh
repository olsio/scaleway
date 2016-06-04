#!/bin/sh

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
        vim && \
    apt-get clean

rm -f /etc/nginx/sites-available/*
rm -f /etc/nginx/sites-enabled/*

rm -rf ./scaleway
git clone https://github.com/olsio/scaleway.git scaleway
cp -R ./scaleway/overlay/* /


curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.1/install.sh | bash
source .bashrc

nvm install v0.10.40

n=$(which node);n=${n%/bin/node}; chmod -R 755 $n/bin/*; sudo cp -r $n/{bin,lib,share} /usr/local

wget -qO ghost.zip https://ghost.org/zip/ghost-latest.zip && \
    rm -rf /var/www && \
    unzip ghost.zip -d /var/www/ && \
    rm -f ghost.zip && \
    cd /var/www && npm install --production && \
    cd -

useradd ghost && chown -R ghost:ghost /var/www

openssl dhparam -out dhparam.pem 4096

ln -sf /etc/nginx/sites-available/olsio /etc/nginx/sites-enabled/olsio

git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
cd /opt/letsencrypt


./letsencrypt-auto certonly -a webroot --webroot-path=/tmp -d donottest.me