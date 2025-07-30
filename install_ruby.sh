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
ARCH="$(dpkg --print-architecture)"

# Install core20 using install_assert.sh
CORE_INFO=$(./snap_download.sh core20 stable "$ARCH" "$DOWNLOAD_DIR")
CORE_ASSERT=$(echo "$CORE_INFO" | grep '^ASSERT=' | cut -d= -f2)
CORE_RESULT=$(./install_assert.sh "$CORE_ASSERT" "$DOWNLOAD_DIR" /snap)
CORE_TARGET=$(echo "$CORE_RESULT" | grep '^TARGET_DIR=' | cut -d= -f2)
ln -sfn "$CORE_TARGET" /snap/core20/current

# Install Ruby 2.7 using install_assert.sh
RUBY_INFO=$(./snap_download.sh ruby 2.7/stable "$ARCH" "$DOWNLOAD_DIR")
RUBY_ASSERT=$(echo "$RUBY_INFO" | grep '^ASSERT=' | cut -d= -f2)
RUBY_RESULT=$(./install_assert.sh "$RUBY_ASSERT" "$DOWNLOAD_DIR" /snap)
RUBY_TARGET=$(echo "$RUBY_RESULT" | grep '^TARGET_DIR=' | cut -d= -f2)
ln -sfn "$RUBY_TARGET" /snap/ruby/current
