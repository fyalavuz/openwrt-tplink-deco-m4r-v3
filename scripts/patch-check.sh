#!/usr/bin/env bash
set -euo pipefail

repo="${OPENWRT_REPO:-https://github.com/caeklol/openwrt.git}"
branch="${OPENWRT_BRANCH:-openwrt-23.05}"
workdir="${TMPDIR:-/tmp}/deco-m4r-v3-patch-check"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

rm -rf "$workdir"
git clone --depth 1 --branch "$branch" "$repo" "$workdir"

git -C "$workdir" apply --check \
  "$repo_root/patches/openwrt-23.05/001-tplink-deco-m4r-v3-local-support.patch"

cp "$repo_root/patches/openwrt-23.05/402-mtd-spi-nor-xmc-add-XM25QH256C.patch" \
  "$workdir/target/linux/ipq40xx/patches-5.15/"

echo "Patch check passed for $repo@$branch"
