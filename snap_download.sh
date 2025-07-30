#!/bin/bash
# download-snap.sh  <snap名>  <トラック/リスク>  [arch] [保存フォルダ]
# 例: ./download-snap.sh ruby 2.7/stable amd64 downloads

set -euo pipefail

SNAP_NAME=${1:? "snap 名を指定してください"}
CHANNEL=${2:-stable}          # 例: "2.7/stable" や "beta"
ARCH=${3:-$(dpkg --print-architecture)}  # 省略時はホストの arch
OUTPUT_DIR=${4:-.}
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
SNAP_ID=$(echo "${INFO_JSON}" | jq -r '."snap-id"')

mkdir -p "${OUTPUT_DIR}"

F_SNAP="${SNAP_NAME}_${REVISION}_${ARCH}.snap"
F_ASSERT="${SNAP_NAME}_${REVISION}.assert"
SNAP_PATH="${OUTPUT_DIR%/}/${F_SNAP}"
ASSERT_PATH="${OUTPUT_DIR%/}/${F_ASSERT}"

echo "▼ download .snap (${SNAP_PATH})"
curl -L -C - -o "${SNAP_PATH}"  "${DOWNLOAD_URL}"

echo "▼ download .assert (${ASSERT_PATH})"
if ! curl -fsSL -o "${ASSERT_PATH}" \
  "https://api.snapcraft.io/api/v1/snaps/assertions/snap-revision/${SNAP_ID}_${REVISION}.assert"; then
  cat >"${ASSERT_PATH}" <<EOF_ASSERT
type: snap-revision
snap-name: ${SNAP_NAME}
snap-revision: ${REVISION}
EOF_ASSERT
fi

cat <<EOF
completed
SNAP=${SNAP_PATH}
ASSERT=${ASSERT_PATH}
EOF
