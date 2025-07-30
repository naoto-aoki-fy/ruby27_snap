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

ARCH="$(dpkg --print-architecture)"

# Install yq from GitHub if not already installed
if ! command -v yq >/dev/null 2>&1; then
  case "$ARCH" in
    amd64)
      YQ_URL="https://github.com/mikefarah/yq/releases/download/v4.47.1/yq_linux_amd64.tar.gz"
      ;;
    arm64)
      YQ_URL="https://github.com/mikefarah/yq/releases/download/v4.47.1/yq_linux_arm64.tar.gz"
      ;;
    *)
      echo "Unsupported architecture for yq: $ARCH" >&2
      exit 1
      ;;
  esac
  TMP_DIR="$(mktemp -d)"
  curl -sSL "$YQ_URL" | tar xz -C "$TMP_DIR"
  install -m 755 "$TMP_DIR"/yq_* /usr/local/bin/yq
  rm -rf "$TMP_DIR"
fi

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

