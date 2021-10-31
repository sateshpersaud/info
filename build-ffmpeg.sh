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
  libtool \
  meson \
  ninja-build \
  pkg-config \
  wget \
  yasm \
  zlib1g-dev \
  libunistring-dev

mkdir --parents /opt/ffmpeg/sources /opt/ffmpeg/build /opt/ffmpeg/bin

export PATH="/opt/ffmpeg/bin:$PATH"
export PKG_CONFIG_PATH=/opt/ffmpeg/build/lib/pkgconfig

cd /opt/ffmpeg/sources
wget https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2
tar xjvf nasm-2.15.05.tar.bz2
cd nasm-2.15.05
CFLAGS="-march=znver2 -O3" ./autogen.sh
PATH="/opt/ffmpeg/bin:$PATH" CFLAGS="-march=znver2 -O3" ./configure --prefix=/opt/ffmpeg/build --bindir=/opt/ffmpeg/bin  --enable-lto
CFLAGS="-march=znver2 -O3" make
make install

cd /opt/ffmpeg/sources
git -C x264 pull 2>/dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git
cd x264
PATH="/opt/ffmpeg/bin:$PATH" PKG_CONFIG_PATH=/opt/ffmpeg/build/lib/pkgconfig ./configure \
  --prefix=/opt/ffmpeg/build \
  --bindir=/opt/ffmpeg/bin \
  --extra-cflags="-march=znver2 -O3" \
  --enable-static \
  --disable-cli \
  --disable-bashcompletion \
  --disable-interlaced \
  --bit-depth=8 \
  --chroma-format=420 \
  --enable-lto
PATH="/opt/ffmpeg/bin:$PATH" make
make install

cd /opt/ffmpeg/sources
git -C fdk-aac pull 2>/dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix=/opt/ffmpeg/build --disable-shared
make
make install

cd /opt/ffmpeg/sources
git -C opus pull 2>/dev/null || git clone --depth 1 https://github.com/xiph/opus.git
cd opus
./autogen.sh
./configure --prefix=/opt/ffmpeg/build --disable-shared --disable-doc --disable-extra-programs
make
make install

cd /opt/ffmpeg/sources
wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjvf ffmpeg-snapshot.tar.bz2
cd ffmpeg
PATH="/opt/ffmpeg/bin:$PATH" PKG_CONFIG_PATH=/opt/ffmpeg/build/lib/pkgconfig ./configure \
  --prefix=/opt/ffmpeg/build \
  --pkg-config-flags="--static" \
  --extra-cflags="-I/opt/ffmpeg/build/include -march=znver2 -O3" \
  --extra-ldflags="-L/opt/ffmpeg/build/lib" \
  --extra-libs="-lpthread -lm" \
  --ld="g++" \
  --bindir=/opt/ffmpeg/bin \
  --enable-gpl \
  --enable-nonfree \
  --disable-ffplay \
  --disable-ffprobe \
  --disable-doc \
  --disable-avdevice \
  --disable-network \
  --enable-libfdk-aac \
  --enable-libopus \
  --enable-libx264 \
  --enable-libxml2 \
  --disable-debug \
  --enable-hardcoded-tables
PATH="/opt/ffmpeg/bin:$PATH" make
make install
