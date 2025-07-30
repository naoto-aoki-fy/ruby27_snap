#!/bin/bash
set -euo pipefail
cd "$(dirname "$BASH_SOURCE")"

./test_download.sh
./test_install.sh
./test_setup.sh
./test_activate.sh
