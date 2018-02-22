#!/bin/bash
set -ex

sed -E -i 's/deb.debian.org/httpredir.debian.org/g' /etc/apt/sources.list
apt update
apt install -y devscripts gdebi-core mc sudo bindfs build-essential python \
	git ccache debhelper autoconf automake apache2-dev
 	libpcre3-dev libxml2-dev pkg-config libyajl-dev zlib1g-dev
 	libcurl4-openssl-dev libgeoip-dev libssl-dev xz-utils

echo 'alias ls="ls --color -Fh"' >> /etc/bash.bashrc
echo 'alias dir="ls -l"' >> /etc/bash.bashrc
echo 'app ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/app
chmod 440 /etc/sudoers.d/app

addgroup --gid 1000 app
adduser --uid 1000 --gid 1000 --disabled-password app
usermod -L app

cp /nginx_modsecurity_build/inithostmount.sh /sbin/inithostmount

rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
rm -rf /nginx_modsecurity_build
