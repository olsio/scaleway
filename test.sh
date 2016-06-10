#!/bin/sh


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
        w3m \
        vim && \
    apt-get clean

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
find ./scaleway/ghost -type f -exec sed -i 's/MAIN_DOMAIN/$MAIN_DOMAIN/g' {} +
find ./scaleway/ghost -type f -exec sed -i 's/ALL_DOMAIN_ALIASES/$ALL_DOMAIN_ALIASES/g' {} +
find ./scaleway/ghost -type f -exec sed -i 's/SMTP_USER/$SMTP_USER/g' {} +
find ./scaleway/ghost -type f -exec sed -i 's/SMTP_PASSWORD/$SMTP_PASSWORD/g' {} +
find ./scaleway/ghost -type f -exec sed -i 's/EMAIL/$EMAIL/g' {} +

find ./scaleway/ghost -type f -exec cat {} +
