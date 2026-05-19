# Build Guide

The build scripts use Docker so the host does not need a native OpenWrt build
environment.

## Requirements

- Docker
- Git
- At least 10 GB free disk space
- A reasonably fast internet connection

## Build

```sh
git clone https://github.com/fyalavuz/openwrt-tplink-deco-m4r-v3.git
cd openwrt-tplink-deco-m4r-v3
make build
```

By default the script builds from:

```text
https://github.com/caeklol/openwrt.git
branch: openwrt-23.05
```

Override if needed:

```sh
OPENWRT_REPO=https://github.com/caeklol/openwrt.git \
OPENWRT_BRANCH=openwrt-23.05 \
MAKE_FLAGS=-j8 \
make build
```

## Output

Build output is written to:

```text
artifacts/
```

Expected important files:

```text
openwrt-ipq40xx-generic-tp-link_deco-m4r-v3-initramfs-uImage.itb
openwrt-ipq40xx-generic-tp-link_deco-m4r-v3-squashfs-factory.bin
openwrt-ipq40xx-generic-tp-link_deco-m4r-v3-squashfs-sysupgrade.bin
openwrt-ipq40xx-generic-tp-link_deco-m4r-v3.manifest
deco-m4r-v3-slot1-kernel.bin
deco-m4r-v3-slot1-rootfs.bin
sha256sums
```

The split files are generated automatically by:

```sh
./scripts/split-sysupgrade.sh artifacts/openwrt-ipq40xx-generic-tp-link_deco-m4r-v3-squashfs-sysupgrade.bin
```

## Why Split The Image?

The tested flashing path writes the slot1 kernel and rootfs partitions directly
from U-Boot:

- `deco-m4r-v3-slot1-kernel.bin` goes to `0x1020000`
- `deco-m4r-v3-slot1-rootfs.bin` goes to `0x1450000`

The split helper finds the squashfs magic (`hsqs`) and separates the kernel FIT
image from the root filesystem.

## Patch Check Only

To check that the local OpenWrt patch still applies:

```sh
make patch-check
```

This does not build firmware.
