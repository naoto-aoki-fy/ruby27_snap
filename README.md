# Ruby 2.7 Snap Installer

This repository contains simple scripts for installing Ruby 2.7 from a Snap package and configuring the environment to use it.

- **snap_download.sh** – Downloads a package from the Snap repository. The
  destination directory for the `.snap` and `.assert` files can be specified as
  an optional argument; the directory is created if it does not exist.
- **snap_install.sh** – Installs a Snap package using downloaded `.assert` and
  `.snap` files, extracting to `/snap/<name>/<revision>/`.
- **setup.sh** – Installs Ruby 2.7 using a downloaded Snap package,
  skipping extraction when the destination directory already exists and only
  running `apt` commands when required packages are missing.
- **activate.sh** – Sets environment variables for running Ruby 2.7 and defines
  a `deactivate` function to restore the previous environment.

## Usage

1. Run `setup.sh` as root to download and extract the Ruby 2.7 Snap package. If the
   extraction directory already exists, that step is skipped.
   Required packages are installed only when missing, so `apt-get update` and
   `apt-get install` are skipped if everything is already present.
2. Source `activate.sh` to update the environment variables for your shell.
   When you are done using this Ruby environment, run `deactivate` to
   restore your previous settings.
3. Use `snap_install.sh <assert> <snap>` to extract a previously downloaded
   package into `/snap/<name>/<revision>/`.

These scripts are experimental and assume a Linux environment with Snap and `squashfs-tools` available.

### Test scripts

Several test helpers are included to verify each part of the installation process.
Run them individually or use `test.sh` to execute all of them in order.

- `test_download.sh` – checks that `snap_download.sh` successfully downloads the
  `.snap` and `.assert` files.
- `test_install.sh` – verifies extraction of a downloaded Snap using
  `snap_install.sh`.
- `test_setup.sh` – runs `setup.sh` and confirms that Ruby is installed under
  `/snap/ruby/current`.
- `test_activate.sh` – sources `activate.sh`, confirms the Ruby version and that
  the environment can be restored.

### Setup script for Codex

```bash
mise settings add idiomatic_version_file_enable_tools "[]"
git clone https://github.com/naoto-aoki-fy/ruby27_snap.git ruby27_snap
./ruby27_snap/setup.sh

echo >> "$HOME/.bashrc"
echo source "$PWD"/ruby27_snap/activate.sh >> "$HOME/.bashrc"
```
