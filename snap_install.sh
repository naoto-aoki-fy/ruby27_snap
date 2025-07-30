#!/bin/bash

# Install a snap package using a downloaded .assert and .snap file
# Usage: ./snap_install.sh <assert-file> <snap-file> [target-dir]
# - <assert-file>: Path to the .assert file
# - <snap-file>:   Path to the corresponding .snap file
# - [target-dir]:  Parent directory for extraction (default /snap)

set -euo pipefail

ASSERT_FILE=${1:?"Path to .assert file required"}
SNAP_FILE=${2:?"Path to .snap file required"}
TARGET_PARENT=${3:-/snap}

SNAP_NAME=$(awk -F': ' '/^snap-name:/ {print $2; exit}' "$ASSERT_FILE")
REVISION=$(awk -F': ' '/^snap-revision:/ {print $2; exit}' "$ASSERT_FILE")

if [[ -z "$SNAP_NAME" || -z "$REVISION" ]]; then
  echo "Failed to parse snap-name or snap-revision from $ASSERT_FILE" >&2
  exit 1
fi


TARGET_DIR="$TARGET_PARENT/$SNAP_NAME/$REVISION"

if [ ! -d "$TARGET_DIR" ]; then
  mkdir -p "$TARGET_DIR"
  unsquashfs -d "$TARGET_DIR" "$SNAP_FILE"
fi

# Create wrapper scripts for commands listed under apps
SNAP_YAML="$TARGET_DIR/meta/snap.yaml"
if [ -f "$SNAP_YAML" ]; then
  mkdir -p /snap/bin
  SNAP_ARCH=$(dpkg --print-architecture)
  for APP in $(yq -r '.apps | keys[]' "$SNAP_YAML"); do
    CMD=$(yq -r ".apps.\"${APP}\".command" "$SNAP_YAML")
    [ "$CMD" = "null" ] && continue
    WRAPPER="/snap/bin/${APP}"
    {
      echo "#!/bin/sh"
      while IFS=$'\t' read -r k v; do
        [ -z "$k" ] && continue
        v="${v//\$SNAP_ARCH/$SNAP_ARCH}"
        v="${v//\$SNAP/$TARGET_DIR}"
        printf 'export %s=%s\n' "$k" "$v"
      done < <(yq -r '.environment // {} | to_entries[] | "\(.key)\t\(.value)"' "$SNAP_YAML")
      while IFS=$'\t' read -r k v; do
        [ -z "$k" ] && continue
        v="${v//\$SNAP_ARCH/$SNAP_ARCH}"
        v="${v//\$SNAP/$TARGET_DIR}"
        printf 'export %s=%s\n' "$k" "$v"
      done < <(yq -r ".apps.\"${APP}\".environment // {} | to_entries[] | \"\\(.key)\\t\\(.value)\"" "$SNAP_YAML")
      printf '%s "$@"\n' "$TARGET_DIR/$CMD"
    } > "$WRAPPER"
    chmod +x "$WRAPPER"
  done
fi

cat <<EOF2
completed
SNAP_FILE=$SNAP_FILE
TARGET_DIR=$TARGET_DIR
EOF2

