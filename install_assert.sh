#!/bin/bash

# Install a snap package using a downloaded .assert file to determine the name and revision
# Usage: ./install_assert.sh <assert-file> [download-dir] [target-dir]
# - <assert-file>: Path to the .assert file
# - [download-dir]: Directory containing the corresponding .snap (default dirname of assert)
# - [target-dir]:   Parent directory for extraction (default /snap)

set -euo pipefail

ASSERT_FILE=${1:?"Path to .assert file required"}
DOWNLOAD_DIR=${2:-$(dirname "$ASSERT_FILE")}
TARGET_PARENT=${3:-/snap}

SNAP_NAME=$(awk -F': ' '/^snap-name:/ {print $2; exit}' "$ASSERT_FILE")
REVISION=$(awk -F': ' '/^snap-revision:/ {print $2; exit}' "$ASSERT_FILE")

if [[ -z "$SNAP_NAME" || -z "$REVISION" ]]; then
  echo "Failed to parse snap-name or snap-revision from $ASSERT_FILE" >&2
  exit 1
fi

SNAP_FILE=$(find "$DOWNLOAD_DIR" -maxdepth 1 -name "${SNAP_NAME}_${REVISION}_*.snap" | head -n 1 || true)
if [ -z "$SNAP_FILE" ]; then
  echo "Snap file for $SNAP_NAME revision $REVISION not found in $DOWNLOAD_DIR" >&2
  exit 1
fi

TARGET_DIR="$TARGET_PARENT/$SNAP_NAME/$REVISION"

if [ ! -d "$TARGET_DIR" ]; then
  mkdir -p "$TARGET_DIR"
  unsquashfs -d "$TARGET_DIR" "$SNAP_FILE"
fi

cat <<EOF2
completed
SNAP_FILE=$SNAP_FILE
TARGET_DIR=$TARGET_DIR
EOF2

