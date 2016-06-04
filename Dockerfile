FROM scaleway/ubuntu:amd64-xenial
MAINTAINER Oliver Schneider <os@ols.io>

# Prepare rootfs for image-builder
RUN /usr/local/sbin/builder-enter

# Install packages
RUN apt-get -q update \
 && apt-get -y -q upgrade \
 && apt-get install -y -q \
	curl \
	iptables \
	iptables-persistent \
	openvpn \
	nginx \
	supervisor \
	zip \
	uuid \
 && apt-get clean

# Patch rootfs
ADD ./overlay/etc/ /etc/
ADD ./overlay/usr/local/ /usr/local/


# Clean rootfs from image-builder
RUN /usr/local/sbin/builder-leave
