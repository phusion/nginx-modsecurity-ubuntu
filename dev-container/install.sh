#!/bin/bash
set -ex

export DEBIAN_FRONTEND=noninteractive

apt update
apt install -y devscripts gdebi-core mc sudo build-essential python \
	ccache debhelper quilt eatmydata nano xz-utils wget git \
	autoconf automake apache2-dev libmodsecurity-dev \
	libpcre3-dev libxml2-dev pkg-config libyajl-dev zlib1g-dev \
	libcurl4-openssl-dev libgeoip-dev libssl-dev

ln -s ../../bin/ccache /usr/lib/ccache/cc
ln -s ../../bin/ccache /usr/lib/ccache/c++

wget -O matchhostfsowner.gz \
	https://github.com/FooBarWidget/matchhostfsowner/releases/download/v0.9.8/matchhostfsowner-0.9.8-x86_64-linux.gz
gunzip matchhostfsowner
chmod +x,+s matchhostfsowner
mv matchhostfsowner /sbin/

echo 'alias ls="ls --color -Fh"' >> /etc/bash.bashrc
echo 'alias dir="ls -l"' >> /etc/bash.bashrc
echo 'app ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/app
chmod 440 /etc/sudoers.d/app

addgroup --gid 1000 app
adduser --uid 1000 --gid 1000 --disabled-password app
usermod -L app

mkdir /home/app/.gnupg
cp /nginx_modsecurity_build/gpg.conf /home/app/.gnupg/gpg.conf
chown -R app: /home/app/.gnupg
chmod 700 /home/app/.gnupg

apt clean
rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
rm -rf /nginx_modsecurity_build
