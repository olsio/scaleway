#!/bin/sh

while [ -z "$DOMAIN" ]
do
  read -p "Enter the main domain for your blog: " DOMAIN
done

while [ -z "$SSL_DOMAINS" ]
do
  read -p "Enter all domains that should be ssl protected: " SSL_DOMAINS
done

while [ -z "$SMTP_USER" ]
do
  read -p "Enter maingun SMTP user: " SMTP_USER
done

while [ -z "$SMTP_PASSWORD" ]
do
  read -s -p "Enter maingun SMTP password: " SMTP_PASSWORD
done

echo $DOMAIN $SSL_DOMAINS $SMTP_USER $SMTP_PASSWORD