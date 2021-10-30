#!/usr/bin/sudo /bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

export DEBIAN_FRONTEND=noninteractive

apt-get --assume-yes --quiet update
apt-get --assume-yes --quiet upgrade
apt-get --assume-yes --quiet dist-upgrade
apt-get --assume-yes --no-install-recommends --quiet install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libgnutls28-dev \
  libtool \
  meson \
  ninja-build \
  pkg-config \
  texinfo \
  wget \
  yasm \
  zlib1g-dev \
  libunistring-dev

mkdir --parents /opt/ffmpeg/sources /opt/ffmpeg/build /opt/ffmpeg/bin

export PATH="/opt/ffmpeg/bin:$PATH"
export PKG_CONFIG_PATH=/opt/ffmpeg/build/lib/pkgconfig

cd /opt/ffmpeg/sources
wget https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2 && \
tar xjvf nasm-2.15.05.tar.bz2 && \
cd nasm-2.15.05 && \
./autogen.sh
PATH="/opt/ffmpeg/bin:$PATH" ./configure --prefix=/opt/ffmpeg/build --bindir=/opt/ffmpeg/bin
PATH="/opt/ffmpeg/bin:$PATH" make
make install
