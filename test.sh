#!/bin/sh

if [ "$#" -ne 4 ]; then
    echo "usage test.sh domain ssl_domains smtp_user smtp_password"
    exit
fi

domain=$1
ssl_domains=$2
smtp_user=$3
smtp_password=$4

echo $domain $ssl_domains $smtp_user $smtp_password