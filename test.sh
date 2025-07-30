#!/bin/bash
set -euo pipefail

./test_download.sh
./test_install.sh
./test_setup.sh
./test_activate.sh
