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
git -C nasm pull 2>/dev/null || git clone --depth 1 https://github.com/netwide-assembler/nasm.git
cd nasm
./autogen.sh
./configure --prefix=/opt/ffmpeg/build --bindir=/opt/ffmpeg/bin
make
make install

cd /opt/ffmpeg/sources
git -C x264 pull 2>/dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git
cd x264
./configure \
  --prefix=/opt/ffmpeg/build \
  --bindir=/opt/ffmpeg/bin \
  --enable-static \
  --enable-pic \
  --disable-cli \
  --disable-bashcompletion \
  --disable-interlaced \
  --bit-depth=8 \
  --chroma-format=420
make
make install
