# Full Flash Backup

Make a full flash backup before writing any firmware.

The tested device has a 32 MiB SPI NOR flash. A correct full backup should be:

```text
33554432 bytes
```

## Network Setup

The tested host setup used:

| Host | IP |
| --- | --- |
| Mac Ethernet | `169.254.30.59/16` |
| Device initramfs/OpenWrt | any address that can reach host |

## Receive On The Host

On macOS, use `nc -d` so netcat does not close because of stdin behavior:

```sh
mkdir -p backups
nc -d -l 9001 > backups/deco-m4r-v3-fullflash.bin
```

## Send From The Device

From an OpenWrt shell on the Deco:

```sh
cat \
  /dev/mtd0ro \
  /dev/mtd1ro \
  /dev/mtd2ro \
  /dev/mtd3ro \
  /dev/mtd4ro \
  /dev/mtd5ro \
  /dev/mtd6ro \
  /dev/mtd7ro \
  /dev/mtd8ro \
  /dev/mtd9ro \
  /dev/mtd10ro \
  /dev/mtd11ro \
  /dev/mtd12ro \
  /dev/mtd13ro \
  /dev/mtd14ro \
  /dev/mtd15ro | nc 169.254.30.59 9001
```

Then verify on the host:

```sh
stat -f '%z %N' backups/deco-m4r-v3-fullflash.bin
shasum -a 256 backups/deco-m4r-v3-fullflash.bin
```

Do not publish this file. It can contain device-specific calibration data, MAC
addresses, and private stock firmware data.

## Known Tested Backup Size

The validated backup size was:

```text
33554432 bytes
```
