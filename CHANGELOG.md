# Changelog

## 2026-05-19

- Documented working TP-Link Deco M4R v3 EU OpenWrt installation path.
- Added local OpenWrt 23.05 patch for board name, rootfs partition label, Wi-Fi
  package selection, LuCI inclusion, and first-boot Wi-Fi defaults.
- Added XMC `XM25QH256C` SPI NOR support patch.
- Added Docker-based build script.
- Added sysupgrade split helper for U-Boot slot1 flashing.
- Added serial pinout, backup, flashing, and recovery docs.

## 2026-05-20

- Added a prominent warning that slot1 U-Boot flashing is not yet proven
  persistent across a full cold power cycle on every unit.
- Documented the observed case where OpenWrt booted after U-Boot `reset` but
  stock TP-Link firmware returned after complete power-off/power-on.
- Documented the likely false-positive warm boot failure mode: U-Boot can boot
  the last TFTP image still present in RAM at `0x84000000`.
