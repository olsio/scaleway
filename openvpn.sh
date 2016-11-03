#!/bin/sh

##############################################################
# Installing base pagages
##############################################################
export DEBIAN_FRONTEND=noninteractive
apt-get -q update && \
    apt-get -y -q -o Dpkg::Options::="--force-confnew" dist-upgrade && \
    apt-get install -y -q -o Dpkg::Options::="--force-confnew" curl \
        curl \
        iptables \
        iptables-persistent \
        openvpn \
        stunnel4 \
        uuid \
        zip \
        git \
        mc \
        wget \
        w3m \
        build-essential \
        vim && \
    apt-get clean

rm -rf ./scaleway
git clone https://github.com/olsio/scaleway.git scaleway

cp -R ./scaleway/openvpn/* /

# Scaleway specific
[ -d /dev/net ] || \
    mkdir -p /dev/net
[ -c /dev/net/tun ] || \
    mknod /dev/net/tun c 10 200
[ -f /etc/openvpn/dh.pem ] || \
    build_key &
[ -f /etc/openvpn/key.pem ] || \
    openssl genrsa -out /etc/openvpn/key.pem 4096
chmod 600 /etc/openvpn/key.pem
[ -f /etc/openvpn/csr.pem ] || \
    openssl req -new -key /etc/openvpn/key.pem -out /etc/openvpn/csr.pem -subj /CN=OpenVPN/
[ -f /etc/openvpn/cert.pem ] || \
    openssl x509 -req -in /etc/openvpn/csr.pem -out /etc/openvpn/cert.pem -signkey /etc/openvpn/key.pem -days 24855
[ -f /etc/stunnel/stunnel.pem ] || \
    cat /etc/openvpn/key.pem /etc/openvpn/cert.pem >> /etc/stunnel/stunnel.pem && \
    sed -i s/ENABLED=0/ENABLED=1/g /etc/default/stunnel4

MY_IP_ADDR=$(wget http://ipinfo.io/ip -qO -)

cat <<EOF > /root/client.ovpn
client
nobind
dev tun
redirect-gateway def1
<key>
`cat /etc/openvpn/key.pem`
</key>
<cert>
`cat /etc/openvpn/cert.pem`
</cert>
<ca>
`cat /etc/openvpn/cert.pem`
</ca>
<dh>
`cat /etc/openvpn/dh.pem`
</dh>
<connection>
remote $MY_IP_ADDR 1194 udp
</connection>
<connection>
remote $MY_IP_ADDR 443 tcp-client
</connection>
EOF

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

scw-sync-kernel-modules
depmod -a
reboot