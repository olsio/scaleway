# scaleway

    MAIN_DOMAIN="$1"
    ALL_DOMAIN_ALIASES="$2"
    SMTP_USER="$3"
    SMTP_PASSWORD="$4"
    EMAIL="$5"
    URL=https://raw.githubusercontent.com/olsio/scaleway/master/ghost.sh
    bash <(curl -s $URL) $MAIN_DOMAIN $ALL_DOMAIN_ALIASES $SMTP_USER $SMTP_PASSWORD $EMAIL