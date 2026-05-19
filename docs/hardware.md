# Hardware and Serial Pinout

## Device

Tested unit:

- TP-Link Deco M4R v3 / AC1200
- EU v3
- IPQ4019
- 256 MiB RAM
- 32 MiB SPI NOR

## Opening The Unit

Opening the Deco is outside the scope of this repository, but the workflow
requires access to the UART pads on the board.

Do not connect any 3.3 V, 5 V, or VCC line from the serial adapter to the Deco.
Only connect GND, TX, and RX.

## UART Parameters

```text
115200 baud
8 data bits
no parity
1 stop bit
no flow control
```

## Generic USB-TTL Adapter

Use a 3.3 V logic-level USB-TTL adapter.

| USB-TTL adapter | Deco UART |
| --- | --- |
| GND | GND |
| RX | TX |
| TX | RX |
| VCC / 3V3 / 5V | Do not connect |

If you see no output, swap TX and RX.

## ESP32-S3 Dev Board As USB-Serial Adapter

The known-working setup used an ESP32-S3 board held in reset so its USB-serial
path could be reused.

| ESP32-S3 dev board | Deco UART |
| --- | --- |
| GND | GND |
| EN / RST | ESP32-S3 GND |
| U0TXD / GPIO43 | Deco TX |
| U0RXD / GPIO44 | Deco RX |
| 3V3 / 5V | Do not connect |

This mapping is specific to the tested ESP32-S3 board. If your board exposes a
separate USB-UART chip pinout, follow that board's labeling.

## Stop U-Boot Autoboot

Power-cycle the Deco and repeatedly type:

```text
tpl
```

Expected U-Boot prompt:

```text
(IPQ40xx) #
```

## Disconnecting Serial After Installation

After OpenWrt is booting from flash, serial is not required for normal use,
LuCI, SSH, reset, or sysupgrade.

Keep the serial setup available for recovery. It is needed if:

- U-Boot recovery is required.
- The device no longer boots.
- A wrong image was written.
- You need to inspect boot logs.

Power the Deco off before removing serial wires.
