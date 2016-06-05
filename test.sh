#!/bin/sh

if [[ -n "$domain" ]]
then
    echo "$domain is not set"
    exit 1
fi

if [[ -n "$ssl_domains" ]]
then
    echo "$ssl_domains is not set"
    exit 1
fi

if [[ -n "$smtp_user" ]]
then
    echo "$smtp_user is not set"
    exit 1
fi

if [[ -n "$smtp_password" ]]
then
    echo "$smtp_password is not set"
    exit 1
fi

echo $domain $ssl_domains $smtp_user $smtp_password