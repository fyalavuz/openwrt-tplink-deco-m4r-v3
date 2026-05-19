# U-Boot Flashing Guide

This guide writes OpenWrt to the stock slot1 kernel/rootfs area from U-Boot.

Read this page completely before running commands.

## Required Files

Build first:

```sh
make build
```

You need:

```text
artifacts/deco-m4r-v3-slot1-kernel.bin
artifacts/deco-m4r-v3-slot1-rootfs.bin
```

Known-good LuCI build sizes:

| File | Decimal | Hex |
| --- | ---: | ---: |
| `deco-m4r-v3-slot1-kernel.bin` | `4390912` | `0x430000` |
| `deco-m4r-v3-slot1-rootfs.bin` | `3998836` | `0x3d0474` |

If your file sizes differ, update the `sf write`, `sf read`, and `cmp.b`
lengths.

## Host Ethernet

The tested host setup:

```text
Mac Ethernet: 169.254.30.59/16
U-Boot IP:    169.254.30.60
```

On macOS, one way to set the host address is through System Settings or:

```sh
sudo ifconfig en8 inet 169.254.30.59 netmask 255.255.0.0 up
```

Replace `en8` with your Ethernet interface.

## Start TFTP Server

From the repository root:

```sh
python3 scripts/serve-tftp.py artifacts
```

Leave it running until flashing is complete.

## Enter U-Boot

Open serial at `115200 8N1`, power-cycle the Deco, and repeatedly type:

```text
tpl
```

Expected prompt:

```text
(IPQ40xx) #
```

## U-Boot Commands

Set IPs:

```text
setenv serverip 169.254.30.59
setenv ipaddr 169.254.30.60
```

Ping the host:

```text
ping 169.254.30.59
```

If ping fails on the first try, wait a few seconds and retry. On the tested
unit, U-Boot sometimes reported PHY down at first and then brought the link up
on a later ping.

### Flash Rootfs

```text
tftpboot 0x84000000 deco-m4r-v3-slot1-rootfs.bin
sf probe
sf erase 0x1450000 0xbb0000
sf write 0x84000000 0x1450000 0x3d0474
sf read 0x85000000 0x1450000 0x3d0474
cmp.b 0x84000000 0x85000000 0x3d0474
```

Expected compare result:

```text
Total of 3998836 byte(s) were the same
```

### Flash Kernel

```text
tftpboot 0x84000000 deco-m4r-v3-slot1-kernel.bin
sf erase 0x1020000 0x430000
sf write 0x84000000 0x1020000 0x430000
sf read 0x85000000 0x1020000 0x430000
cmp.b 0x84000000 0x85000000 0x430000
```

Expected compare result:

```text
Total of 4390912 byte(s) were the same
```

Boot:

```text
reset
```

## First Boot

Wait at least 60 seconds. The first boot formats the `rootfs_data` overlay.

Expected signs:

```text
VFS: Mounted root (squashfs filesystem) readonly on device 31:15.
1 squashfs-split partitions found on MTD device rootfs
rootfs_data
```

After boot:

```text
http://192.168.1.1
```

Login:

```text
user: root
password: empty
```

Set a root password immediately.
