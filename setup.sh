#!/bin/bash

set -euo pipefail
cd "$(dirname "$BASH_SOURCE")"

# Skip apt operations when all required packages are installed
PACKAGES=(squashfs-tools curl jq yq)
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

ARCH="$(dpkg --print-architecture)"

DOWNLOAD_DIR="."

# Install core20 using snap_install.sh
CORE_INFO=$(./snap_download.sh core20 stable "$ARCH" "$DOWNLOAD_DIR")
CORE_ASSERT=$(echo "$CORE_INFO" | grep '^ASSERT=' | cut -d= -f2)
CORE_SNAP=$(echo "$CORE_INFO" | grep '^SNAP=' | cut -d= -f2)
CORE_RESULT=$(./snap_install.sh "$CORE_ASSERT" "$CORE_SNAP" /snap)
CORE_TARGET=$(echo "$CORE_RESULT" | grep '^TARGET_DIR=' | cut -d= -f2)
ln -sfn "$CORE_TARGET" /snap/core20/current

# Install Ruby 2.7 using snap_install.sh
RUBY_INFO=$(./snap_download.sh ruby 2.7/stable "$ARCH" "$DOWNLOAD_DIR")
RUBY_ASSERT=$(echo "$RUBY_INFO" | grep '^ASSERT=' | cut -d= -f2)
RUBY_SNAP=$(echo "$RUBY_INFO" | grep '^SNAP=' | cut -d= -f2)
RUBY_RESULT=$(./snap_install.sh "$RUBY_ASSERT" "$RUBY_SNAP" /snap)
RUBY_TARGET=$(echo "$RUBY_RESULT" | grep '^TARGET_DIR=' | cut -d= -f2)
ln -sfn "$RUBY_TARGET" /snap/ruby/current

