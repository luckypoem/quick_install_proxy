#!/bin/sh
###################################
# set these before run!!
DOMAIN_NAME=103.253.25.150
DEFAULT_PROXY_AUTH_USER=proxy
DEFAULT_PROXY_AUTH_PASSWORD=Jasdfa79aslocUsdRqcda3

SQUID_VERSION=3.5.17

###################################
DOWNLOAD_DIR=~/Downloads/
SOURCE_SQUID_CONF="`pwd`/squid.conf"
DEST_SQUID_CONF=/etc/squid/squid.conf

SOURCE_SQUID_SH="`pwd`/squid.sh"
DEST_SQUID_SH=/etc/init.d/squid

DEST_PRIVATE_PEM=/etc/squid/squid_private.pem
DEST_PUB_PEM=/etc/squid/squid_proxy.pem
DEST_PROXY_USER_AUTH_FILE=/etc/squid/auth_users.pwd

mkdir -p $DOWNLOAD_DIR


if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

echo "Update packages list"
apt-get update

echo "Build dependencies"
apt-get -y install build-essential libssl-dev apache2-utils
aptitude update
aptitude build-dep squid3

echo "Download source code"
cd $DOWNLOAD_DIR

wget http://www.squid-cache.org/Versions/v3/3.5/squid-${SQUID_VERSION}.tar.gz
tar zxvf squid-${SQUID_VERSION}.tar.gz
cd squid-${SQUID_VERSION}

# when run with root, lib install to /lib/squid/, how to change it?
echo "Build binaries"
./configure --prefix=/usr/local \
  --localstatedir=/var/squid \
  --libexecdir=/usr/local/lib/squid \
  --srcdir=. \
  --datadir=${prefix}/share/squid \
  --sysconfdir=/etc/squid \
  --with-default-user=proxy \
  --with-logdir=/var/log/squid \
  --with-pidfile=/var/run/squid.pid \
  --with-openssl

make

echo "Stop running service"
service squid stop

echo "Install binaries"
make install

#echo "Download libraries"
#wget -O /usr/lib/squid-lib.tar.gz http://e7d.github.io/resources/squid-lib.tar.gz
#
#echo "Install libraries"
#tar zxvf squid-lib.tar.gz

echo "Cleanup temporary files"
rm -rf $DOWNLOAD_DIR

echo "Create configuration file"
rm -rf $DEST_SQUID_CONF
cp $SOURCE_SQUID_CONF $DEST_SQUID_CONF

echo "Create users pasword file, only -m encryption will OK(why)"
htpasswd -c -m -b $DEST_PROXY_USER_AUTH_FILE $DEFAULT_PROXY_AUTH_USER $DEFAULT_PROXY_AUTH_PASSWORD

echo "Create service executable file"
cp $SOURCE_SQUID_SH $DEST_SQUID_SH
chmod +x $DEST_SQUID_SH

echo "Prepare environment for first start"
mkdir /var/log/squid
mkdir /var/cache/squid
mkdir /var/spool/squid
chown -cR proxy /var/log/squid
chown -cR proxy /var/cache/squid
chown -cR proxy /var/spool/squid
squid -z

echo "generate the self-signed cert for squild and chrome"
# interative ask you for params. set CommonName to the ip of VPS

openssl req -new -x509 -days 3650 -newkey rsa:2048 -nodes -keyout $DEST_PRIVATE_PEM  -subj "/C=US/ST=Oregon/L=Portland/CN=$DOMAIN_NAME" -out $DEST_PUB_PEM
chmod 400 $DEST_PRIVATE_PEM
chmod 400 $DEST_PUB_PEM

exit 0
