# scaleway

    domain="donottest.me"
    ssl_domains="donottest.me"
    smtp_user=no-reploy@donottest.me
    smtp_password=foo
    curl -o- https://raw.githubusercontent.com/olsio/scaleway/master/test.sh | bash -s $domain $ssl_domains $smtp_user $smtp_password