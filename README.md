# scaleway

    MAIN_DOMAIN="donottest.me"
    ALL_DOMAIN_ALIASES="donottest.me,www.donottest.me"
    SMTP_USER=""
    SMTP_PASSWORD=""
    EMAIL="os@ols.io"
    URL=https://raw.githubusercontent.com/olsio/scaleway/master/ghost.sh
    bash <(curl -s $URL) $MAIN_DOMAIN $ALL_DOMAIN_ALIASES $SMTP_USER $SMTP_PASSWORD $EMAIL