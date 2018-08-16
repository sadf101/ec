#!/bin/bash

HOSTPKGS="
multistrap
qemu
qemu-user-static
binfmt-support
dpkg-cross
"

# All must be armhf !
CCPKGS="
libdbus-1-dev:armhf
libdbus-c++-1-0:armhf
libdbus-c++-dev:armhf
libavahi-client-dev:armhf
libavahi-client3:armhf
libasound2-dev:armhf
libssh-dev:armhf
libglu1-mesa-dev:armhf
libglew-dev:armhf
libpython-dev:armhf
libfribidi-dev:armhf
libavcodec-dev:armhf
libbz2-dev:armhf
libcdio-dev:armhf
libexpat1-dev:armhf
libfreetype6-dev:armhf
libgl1-mesa-dev:armhf
libglu1-mesa-dev:armhf
libjpeg62-turbo-dev:armhf
liblzo2-dev:armhf
libmicrohttpd-dev:armhf
libpcre3-dev:armhf
libpng12-dev:armhf
libpulse-dev:armhf
libsamplerate0-dev:armhf
libsdl1.2-dev:armhf
libsdl-mixer1.2-dev:armhf
libsqlite3-dev:armhf
libtiff5-dev:armhf
libtinyxml-dev:armhf
zlib1g-dev:armhf
libmad0-dev:armhf
libmp3lame-dev:armhf
libmpeg2-4-dev:armhf
libogg-dev:armhf
libvorbis-dev:armhf
libcap-dev:armhf
libjansson-dev:armhf
libboost-dev:armhf
libass-dev:armhf
libmodplug1:armhf
libcurl3-gnutls:armhf
libcurl4-gnutls-dev:armhf
libbluetooth3:armhf
libbluetooth-dev:armhf
libyajl2:armhf
libyajl-dev:armhf
libjasper-dev:armhf
libsdl-image1.2-dev:armhf
libudev-dev:armhf
libxml2-dev:armhf
libavformat-dev:armhf
libavcodec-extra-56:armhf
libcups2:armhf
libdbus-glib-1-dev:armhf
libnfs-dev:armhf
libreadline-dev:armhf
libmodplug1:armhf
libncurses5-dev
build-essential
vim
autoconf2.13
libtool
libmysqlclient-dev
pkg-config
cmake
swig
openjdk-7-jre-headless
gawk
gperf
unzip
ccache
bc
u-boot-tools
bison
flex
autopoint
"

# to be solved
# libmysqlclient-dev:armhf
# libmodplug-dev
# python conflicts
# libpython-dev:armhf
# libsmbclient-dev:armhf

#PRE: git repo files are in correct places

echo "+++Begin genCCEnv.sh+++"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#MID: script run as root

# can do ... [ -x "/bin/asdf" ] || apt... 
sudo apt-get -y install cdebootstrap
cdebootstrap -f minimal --arch=amd64 jessie jess http://snapshot.debian.org/archive/debian/20171231T180144Z/
mount --bind /proc jess/proc

# might not be needed ???
cd jess
mkdir src
cd ..
mount --bind imx6Platform/src jess/src

chroot jess apt-get update
chroot jess /bin/bash -e << 'END'
  apt-get -y install curl
  echo "deb http://emdebian.org/tools/debian jessie main" > /etc/apt/sources.list.d/crosstools.list
  curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | apt-key add -
  apt-get update
END

chroot jess /bin/bash -e << 'ENDA'
  dpkg --add-architecture armhf
  apt-get update
  apt-get -y install crossbuild-essential-armhf
  # chroot jess apt-get -y --force-yes install $CCPKGS
  # dpkg-query -l > envState.txt
ENDA

chroot jess apt-get -y install $CCPKGS
#chroot jess apt-get -y --force-yes install $CCPKGS
chroot jess dpkg-query -l > /envState.txt

sudo apt-get -y install $HOSTPKGS
# ---- install the Problem Packages

cd imx6Platform
sudo CCCHROOT=../jess ./genrootfs.sh

echo "+++End genCCEnv.sh+++"

#POST: Cross compile environment setup

