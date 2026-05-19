# Patch Notes

## `001-tplink-deco-m4r-v3-local-support.patch`

This patch applies to the OpenWrt tree and contains the local device fixes used
for the tested build.

### Compatible String

Changes the DTS compatible string from:

```text
tp-link,deco-m4r-v3
```

to:

```text
tplink,deco-m4r-v3
```

This matches OpenWrt board naming conventions and lets board-specific scripts
match the device cleanly.

### Rootfs Label

Changes the slot1 rootfs partition label from:

```text
1:rootfs
```

to:

```text
rootfs
```

This is required for the tested build to detect the root filesystem and create
the persistent `rootfs_data` split.

### Device Packages

Enables:

```text
ipq-wifi-tplink_deco-m4r-v3
luci
```

The first package supplies the Wi-Fi board data. The second includes the LuCI
web interface in the generated image.

### First-Boot Wi-Fi Defaults

Adds:

```text
/etc/uci-defaults/99-deco-m4r-v3-wifi
```

The script runs only when:

```text
board_name == tplink,deco-m4r-v3
```

It enables both radios and sets:

```text
DecoM4-2G / openwrt1234
DecoM4-5G / openwrt1234
country TR
```

## `402-mtd-spi-nor-xmc-add-XM25QH256C.patch`

Adds support for the XMC `XM25QH256C` SPI NOR flash:

```text
JEDEC: 204019
Size: 32768 KiB
Erase: 64 KiB sectors
```

Without this, the tested unit's flash chip is not identified correctly by the
kernel.
