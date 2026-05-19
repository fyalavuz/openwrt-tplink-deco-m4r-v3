#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
  build-essential clang flex bison g++ gawk gettext git libncurses-dev \
  libssl-dev python3 python3-distutils python3-setuptools python3-pyelftools \
  rsync swig unzip zlib1g-dev file wget ccache libelf-dev qemu-utils \
  subversion time xsltproc zstd

if ! id -u build >/dev/null 2>&1; then
  useradd -m build
fi

mkdir -p /build

if [ ! -d /build/openwrt/.git ]; then
  git clone --depth 1 --branch "$OPENWRT_BRANCH" "$OPENWRT_REPO" /build/openwrt
fi

chown -R build:build /build/openwrt

su build -s /bin/bash -c '
set -euo pipefail
cd /build/openwrt
git fetch --depth 1 origin "$OPENWRT_BRANCH"
git reset --hard FETCH_HEAD
git clean -fd -e dl/
git apply /repo/patches/openwrt-23.05/001-tplink-deco-m4r-v3-local-support.patch
cp /repo/patches/openwrt-23.05/402-mtd-spi-nor-xmc-add-XM25QH256C.patch target/linux/ipq40xx/patches-5.15/
cp /repo/configs/openwrt-23.05/deco-m4r-v3.config .config
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig
make ${MAKE_FLAGS}
'

mkdir -p /out
cp -v /build/openwrt/bin/targets/ipq40xx/generic/*deco-m4r-v3* /out/
cp -v /build/openwrt/bin/targets/ipq40xx/generic/sha256sums /out/

/repo/scripts/split-sysupgrade.sh \
  /out/openwrt-ipq40xx-generic-tp-link_deco-m4r-v3-squashfs-sysupgrade.bin \
  /out/deco-m4r-v3-slot1-kernel.bin \
  /out/deco-m4r-v3-slot1-rootfs.bin

ls -lh /out/*deco-m4r-v3*
