#!/bin/bash

# Install a snap package from a pre-downloaded .snap file
# Usage: ./install_snap.sh <snap-name> <download-dir> [target-dir]
# - <snap-name>:    Name of the snap (e.g. ruby)
# - <download-dir>: Directory containing the downloaded .snap file
# - [target-dir]:   Parent directory for extraction (default /snap)

set -euo pipefail

SNAP_NAME=${1:?"Snap name required"}
DOWNLOAD_DIR=${2:?"Path to downloaded snaps required"}
TARGET_PARENT=${3:-/snap}

# Locate the snap file
SNAP_FILE=$(find "$DOWNLOAD_DIR" -maxdepth 1 -name "${SNAP_NAME}_*.snap" | head -n 1 || true)
if [ -z "$SNAP_FILE" ]; then
  echo "Snap file for $SNAP_NAME not found in $DOWNLOAD_DIR" >&2
  exit 1
fi

REVISION=$(basename "$SNAP_FILE" | awk -F_ '{print $2}')
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
