# Verification Checklist

After flashing, verify from serial or SSH.

## Board

```sh
ubus call system board
```

Expected:

```json
{
  "model": "TP-Link Deco M4R v3",
  "board_name": "tplink,deco-m4r-v3",
  "rootfs_type": "squashfs"
}
```

## Overlay

```sh
df -h /overlay
mount | grep overlay
```

Expected:

```text
/dev/mtdblock16 on /overlay type jffs2
overlayfs:/overlay on / type overlay
```

## LuCI

```sh
opkg list-installed | grep -E '^(luci|uhttpd|rpcd-mod-luci)'
/etc/init.d/uhttpd status
netstat -ltnp | grep ':80 '
```

Expected:

```text
running
0.0.0.0:80
:::80
```

## Wi-Fi

```sh
uci -q show wireless | grep -E 'radio[01].disabled|radio[01].country|default_radio[01].ssid'
wifi status | grep -E '"up"|"ssid"|"disabled"|"pending"'
```

Expected:

```text
wireless.radio0.disabled='0'
wireless.radio0.country='TR'
wireless.default_radio0.ssid='DecoM4-2G'
wireless.radio1.disabled='0'
wireless.radio1.country='TR'
wireless.default_radio1.ssid='DecoM4-5G'
```

Both radios should show:

```text
"up": true
"pending": false
"disabled": false
```

## MAC Addresses

Visible network interfaces should use MACs derived from device data, not the
random internal `eth0` MAC.

On the tested unit:

```text
wan:   base MAC
lan:   base MAC + 1
wlan0: base MAC + 2
wlan1: base MAC + 3
```
