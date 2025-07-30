#!/bin/bash
# download-snap.sh  <snap名>  <トラック/リスク>  [arch]
# 例: ./download-snap.sh ruby 2.7/stable amd64

set -euo pipefail

SNAP_NAME=${1:? "snap 名を指定してください"}
CHANNEL=${2:-stable}          # 例: "2.7/stable" や "beta"
ARCH=${3:-$(dpkg --print-architecture)}  # 省略時はホストの arch
SERIES=16                     # 現行デバイス・シリーズは 16 で固定

# --- 1) メタデータ取得 -------------------------------------------------------
INFO_JSON=$(curl -sSL \
  -H "Snap-Device-Series: ${SERIES}" \
  "https://api.snapcraft.io/v2/snaps/info/${SNAP_NAME}")

# --- 2) channel-map から欲しいリビジョンを抜き出す ---------------------------
ENTRY=$(echo "${INFO_JSON}" | jq \
  --arg chan "${CHANNEL}" --arg arch "${ARCH}" \
  '.["channel-map"][] | select(.channel.name==$chan and .channel.architecture==$arch)')

REVISION=$(echo "${ENTRY}"   | jq -r '.revision')
DOWNLOAD_URL=$(echo "${ENTRY}" | jq -r '.download.url')
SNAP_ID=$(echo "${INFO_JSON}" | jq -r '.snap_id')

F_SNAP="${SNAP_NAME}_${REVISION}_${ARCH}.snap"
F_ASSERT="${SNAP_NAME}_${REVISION}.assert"

echo "▼ download .snap (${F_SNAP})"
curl -L -C - -o "${F_SNAP}"  "${DOWNLOAD_URL}"

echo "▼ download .assert (${F_ASSERT})"
curl -sSL -o "${F_ASSERT}" \
  "https://api.snapcraft.io/api/v1/snaps/assertions/snap-revision/${SNAP_ID}_${REVISION}.assert"

cat <<EOF
completed
SNAP=${F_SNAP}
ASSERT=${F_ASSERT}
EOF
