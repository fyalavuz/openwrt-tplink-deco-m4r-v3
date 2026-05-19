#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
  echo "Usage: $0 <sysupgrade.bin> [kernel-out.bin] [rootfs-out.bin]" >&2
  exit 2
fi

sysupgrade="$1"
kernel_out="${2:-artifacts/deco-m4r-v3-slot1-kernel.bin}"
rootfs_out="${3:-artifacts/deco-m4r-v3-slot1-rootfs.bin}"

if [ ! -f "$sysupgrade" ]; then
  echo "sysupgrade image not found: $sysupgrade" >&2
  exit 1
fi

offset="$(LC_ALL=C grep -abo 'hsqs' "$sysupgrade" | head -n 1 | cut -d: -f1)"

if [ -z "$offset" ]; then
  echo "could not find squashfs magic ('hsqs') in $sysupgrade" >&2
  exit 1
fi

if [ $((offset % 65536)) -ne 0 ]; then
  echo "unexpected squashfs offset $offset; not aligned to 64 KiB" >&2
  exit 1
fi

blocks=$((offset / 65536))

mkdir -p "$(dirname "$kernel_out")" "$(dirname "$rootfs_out")"
dd if="$sysupgrade" of="$kernel_out" bs=65536 count="$blocks"
dd if="$sysupgrade" of="$rootfs_out" bs=65536 skip="$blocks"

printf 'kernel offset: 0x%x (%d bytes)\n' "$offset" "$offset"
printf 'kernel image:  %s\n' "$kernel_out"
printf 'rootfs image:  %s\n' "$rootfs_out"
