gzip_vary on;
gzip_comp_level 6;
gzip_buffers 16 8k;
gzip_http_version 1.1;
gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

server {

  listen 443 ssl http2;
  listen [::]:443 ssl http2 ipv6only=on;
  http2_idle_timeout 300;
  keepalive_timeout 300;

  server_name MAIN_DOMAIN;

  ssl_certificate /etc/letsencrypt/live/MAIN_DOMAIN/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/MAIN_DOMAIN/privkey.pem;
  ssl_trusted_certificate /etc/letsencrypt/live/MAIN_DOMAIN/fullchain.pem;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 24h;
  ssl_buffer_size 1400;
  ssl_stapling on;
  ssl_stapling_verify on;
  ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
  add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
  ssl_dhparam /etc/letsencrypt/dh/dhparam.pem;
  resolver 8.8.8.8 8.8.4.4 valid=300s;

  root /var/www/html

  index index.html index.htm index.nginx-debian.html;

  location / {
    # First attempt to serve request as file, then
    # as directory, then fall back to displaying a 404.
    try_files $uri $uri/ =404;
  }
}

server {
  listen 80 default_server;
  listen [::]:80 default_server ipv6only=on;

  server_name MAIN_DOMAIN;

  location '/.well-known/acme-challenge' {
    default_type "text/plain";
    root /tmp/letsencrypt-auto;
  }

  location / {
    return 301 https://$host$request_uri;
  }
}
