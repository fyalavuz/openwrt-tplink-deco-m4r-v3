# Recovery and Troubleshooting

## Reset Button Behavior

After OpenWrt is flashed, the reset button does not restore TP-Link stock
firmware. It resets OpenWrt configuration and boots OpenWrt again.

If the image contains the first-boot defaults from this repo, Wi-Fi will come
back enabled after reset:

```text
DecoM4-2G / openwrt1234
DecoM4-5G / openwrt1234
```

## `http://192.168.1.1` Opens The Wrong Router

This usually means your computer is still routed through another router that
also uses `192.168.1.1`.

Check on macOS:

```sh
route -n get 192.168.1.1
arp -a
```

If it points to your ISP router, disconnect from that network and connect only
to the Deco, either by Ethernet LAN or Deco Wi-Fi.

Use:

```text
http://192.168.1.1
```

not:

```text
https://192.168.1.1
```

## Phone Says Connection Failed

Try:

1. Forget the Deco Wi-Fi network and reconnect.
2. Disable mobile data temporarily.
3. Try `DecoM4-2G` first.
4. Open `http://192.168.1.1` explicitly.

Some phones route captive/no-internet Wi-Fi traffic through mobile data unless
mobile data is disabled.

## LuCI Is Missing

Old builds without `luci` will not show the web interface even if OpenWrt boots.

This repo's current build includes:

```text
luci
uhttpd
uhttpd-mod-ubus
rpcd-mod-luci
```

To verify from serial or SSH:

```sh
opkg list-installed | grep -E '^(luci|uhttpd|rpcd-mod-luci)'
/etc/init.d/uhttpd status
netstat -ltnp | grep ':80 '
```

## U-Boot Ping Fails

U-Boot may show all PHYs down on the first attempt:

```text
eth0 PHY0 Down
eth0 PHY1 Down
...
ping failed
```

Wait a few seconds and retry:

```text
ping 169.254.30.59
```

On the tested unit, PHY3 eventually came up:

```text
eth0 PHY3 up Speed :100 Full duplex
host 169.254.30.59 is alive
```

## `sf erase` Shows No Success Text

On the tested U-Boot, `sf erase` sometimes returned to the prompt without a
clear success line. Continue only if the prompt returns normally and no error is
printed. Always verify with `sf read` + `cmp.b` after writing.

## Device Boots But Overlay Is Temporary

If you see:

```text
mount_root: jffs2 not ready yet, using temporary tmpfs overlay
```

on first boot, wait. The device may still be formatting `rootfs_data`.

After a successful second boot:

```sh
df -h /overlay
mount | grep overlay
```

Expected:

```text
/dev/mtdblock16 on /overlay type jffs2
overlayfs:/overlay on / type overlay
```

## Serial Recovery

If the device does not boot:

1. Reconnect serial.
2. Stop U-Boot with `tpl`.
3. Start the TFTP server again.
4. Reflash the known-good split kernel/rootfs.

Do not erase bootloader, ART, OPAQUE, or calibration partitions.
