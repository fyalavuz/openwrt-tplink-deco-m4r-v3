.PHONY: build split patch-check

build:
	./scripts/build-openwrt.sh

split:
	./scripts/split-sysupgrade.sh artifacts/openwrt-ipq40xx-generic-tp-link_deco-m4r-v3-squashfs-sysupgrade.bin

patch-check:
	./scripts/patch-check.sh
