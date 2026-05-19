#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BUILD_VOLUME="${BUILD_VOLUME:-owrt-deco-m4v3-build}"
OUT_DIR="${OUT_DIR:-$REPO_ROOT/artifacts}"
OPENWRT_REPO="${OPENWRT_REPO:-https://github.com/caeklol/openwrt.git}"
OPENWRT_BRANCH="${OPENWRT_BRANCH:-openwrt-23.05}"
MAKE_FLAGS="${MAKE_FLAGS:--j$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4)}"

mkdir -p "$OUT_DIR"

docker run --rm \
  -e OPENWRT_REPO="$OPENWRT_REPO" \
  -e OPENWRT_BRANCH="$OPENWRT_BRANCH" \
  -e MAKE_FLAGS="$MAKE_FLAGS" \
  -v "$BUILD_VOLUME:/build" \
  -v "$REPO_ROOT:/repo:ro" \
  -v "$OUT_DIR:/out" \
  debian:bookworm \
  bash /repo/scripts/container-build.sh
