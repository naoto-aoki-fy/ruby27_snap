#!/bin/bash

set -euo pipefail
cd "$(dirname "$BASH_SOURCE")"

# Skip apt operations when all required packages are installed
PACKAGES=(squashfs-tools curl jq)
MISSING=()
for pkg in "${PACKAGES[@]}"; do
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    MISSING+=("$pkg")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  apt-get update
  apt-get install -y "${MISSING[@]}"
fi

DOWNLOAD_DIR="."
SNAP_DIR="/opt/ruby27"

INFO=$(./snap_download.sh ruby 2.7/stable "$(dpkg --print-architecture)" "$DOWNLOAD_DIR")
SNAP_FILE=$(echo "$INFO" | grep '^SNAP=' | cut -d= -f2)

if [ ! -d "$SNAP_DIR" ]; then
  unsquashfs -d "$SNAP_DIR" "$SNAP_FILE"
fi

mkdir -p /snap/core20/current/lib64
ln -sf /lib64/ld-linux-x86-64.so.2 /snap/core20/current/lib64/ld-linux-x86-64.so.2
