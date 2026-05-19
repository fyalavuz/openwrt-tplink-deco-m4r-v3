# OpenWrt for TP-Link Deco M4R v3

Unofficial OpenWrt build notes, patches, and recovery-oriented flashing guide
for the TP-Link Deco M4R v3 / AC1200.

This repository is meant to be practical: it contains the exact local patches,
build scripts, pinout notes, backup steps, and U-Boot flashing commands used to
bring a Deco M4R v3 EU unit up on OpenWrt 23.05.

> This is not an official OpenWrt repository and is not affiliated with
> TP-Link. You can permanently brick your device if you write the wrong flash
> region. Make a full flash backup before writing anything.

## Tested Hardware

| Item | Value |
| --- | --- |
| Device | TP-Link Deco M4R v3 / AC1200 |
| Region | EU v3 tested |
| SoC | Qualcomm IPQ4019 |
| RAM | 256 MiB |
| Flash | 32 MiB SPI NOR |
| Detected flash | `XM25QH256C`, JEDEC `204019` |
| Bootloader | U-Boot 2012.07 based TP-Link build |
| OpenWrt base | `caeklol/openwrt`, branch `openwrt-23.05` |

## What Works

- Booting OpenWrt from the stock SPI NOR slot1 layout.
- Persistent squashfs + JFFS2 overlay.
- Ethernet LAN/WAN ports.
- 2.4 GHz and 5 GHz ath10k Wi-Fi.
- TP-Link board data package for this device.
- LuCI web interface included in the generated image.
- Default Wi-Fi enabled on first boot.
- Serial/U-Boot recovery path.

## What This Repo Adds

- DTS compatibility fix: `tp-link,deco-m4r-v3` to `tplink,deco-m4r-v3`.
- Rootfs partition label fix so OpenWrt creates `rootfs_data`.
- XMC `XM25QH256C` SPI NOR support.
- Correct device Wi-Fi board package.
- First-boot UCI defaults for enabled Wi-Fi and LuCI-ready setup.
- Scripts to build, split, and serve images for U-Boot TFTP flashing.

## Default Image Behavior

The generated image includes LuCI and enables both radios on first boot:

| Band | SSID | Password |
| --- | --- | --- |
| 2.4 GHz | `DecoM4-2G` | `openwrt1234` |
| 5 GHz | `DecoM4-5G` | `openwrt1234` |

Country is set to `TR` in the local defaults. Change the Wi-Fi password and
country code after first login.

LuCI:

- URL: `http://192.168.1.1`
- User: `root`
- Password: empty until you set one

Use `http`, not `https`, unless you add HTTPS support later.

## Quick Start

Install Docker, then run:

```sh
git clone https://github.com/fyalavuz/openwrt-tplink-deco-m4r-v3.git
cd openwrt-tplink-deco-m4r-v3
make build
```

Build output appears under `artifacts/`.

The important files for U-Boot flashing are:

- `artifacts/deco-m4r-v3-slot1-kernel.bin`
- `artifacts/deco-m4r-v3-slot1-rootfs.bin`

Read the full guide before flashing:

- [Hardware and serial pinout](docs/hardware.md)
- [Build guide](docs/build.md)
- [Full flash backup](docs/backup.md)
- [U-Boot flashing guide](docs/flashing.md)
- [Recovery and troubleshooting](docs/recovery.md)
- [Patch notes](docs/patches.md)
- [Post-flash verification](docs/verification.md)

## Known-Good Reference Build

The known-good image built during validation had:

| File | Size | SHA256 |
| --- | ---: | --- |
| `openwrt-ipq40xx-generic-tp-link_deco-m4r-v3-squashfs-sysupgrade.bin` | `8389748` | `ab3d74b8e6f46e178d2a4ce2cd0d5ecfea861cca222dc54598796d2ee9ad559b` |
| `deco-m4r-v3-slot1-kernel.bin` | `4390912` | `658ef27747d53abdea01120caefacd5b7e116f05e3749d59c699d6a253549a0b` |
| `deco-m4r-v3-slot1-rootfs.bin` | `3998836` | `a485b25e3f74d94be320e445a86c676a1fdc60a9dd397d08485e7cecbbd1c067` |

These binaries are intentionally not committed. Build them locally so the
source, patches, and resulting images stay auditable.

## Flash Layout Used By This Guide

This guide writes only the inactive slot1 kernel/rootfs regions:

| Region | Offset | Size |
| --- | ---: | ---: |
| `1:HLOS` kernel | `0x1020000` | `0x430000` |
| `rootfs` | `0x1450000` | erase `0xbb0000` |

The rootfs image size changes with the build. The known-good LuCI image rootfs
size is `0x3d0474`. Always check your generated file size before using `sf write`.

## License

OpenWrt is GPL-2.0 licensed. The patches and scripts here are provided under
GPL-2.0-only for compatibility with the OpenWrt tree they modify.
