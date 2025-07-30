# Snap Package Manual Installer

This repository contains simple scripts for manually installing Snap packages from downloaded `.snap` and `.assert` files. Ruby 2.7 is used as an example, but any Snap package can be installed in the same way.

- **snap/snap_download.sh** – Downloads a package from the Snap repository. The
  destination directory for the `.snap` and `.assert` files can be specified as
  an optional argument; the directory is created if it does not exist.
- **snap/snap_install.sh** – Installs a Snap package using downloaded `.assert` and
  `.snap` files, extracting to `/snap/<name>/<revision>/` and creating
  wrapper scripts under `/snap/bin` for the commands defined in
  `meta/snap.yaml`.
- **snap/snap_activate.sh** – Temporarily adds `/snap/bin` to the `PATH` and
  defines a `snap_deactivate` function to restore the previous value. This makes
  the commands extracted by `snap_install.sh` available in the current shell.
- **examples/setup_ruby27.sh** – Example script that installs Ruby 2.7 using these helpers.
  Extraction is skipped when the destination directory already exists and `apt`
  commands are run only when required packages are missing.

## Usage

1. Run `examples/setup_ruby27.sh` as root to download and install Ruby 2.7 as an example. If the
   extraction directory already exists, that step is skipped. Required packages
   are installed only when missing, so `apt-get update` and `apt-get install`
   are skipped if everything is already present.
2. The wrapper scripts under `/snap/bin` make the installed commands available
   automatically; no activation step is required.
3. Use `snap_install.sh <assert> <snap>` to extract a previously downloaded
   package into `/snap/<name>/<revision>/`. Wrapper scripts are created under
   `/snap/bin` so the commands can be executed without specifying the full path.
4. To install a different Snap package, call `snap_download.sh` and
   `snap_install.sh` with the desired package name and channel.

These scripts are experimental and assume a Linux environment with Snap and `squashfs-tools` available.

### Test scripts

Several test helpers are included to verify each part of the installation process.
Run them individually or use `tests/test.sh` to execute all of them in order.

- `test_download.sh` – checks that `snap/snap_download.sh` successfully downloads the
  `.snap` and `.assert` files.
- `test_install.sh` – verifies extraction of a downloaded Snap using
  `snap/snap_install.sh`.
- `test_setup.sh` – runs the example script and confirms that Ruby is installed under
  `/snap/ruby/current`.

### ruby2.7 setup script for Codex

```bash
mise settings add idiomatic_version_file_enable_tools "[]"
git clone https://github.com/naoto-aoki-fy/ruby27_snap.git ruby27_snap
./ruby27_snap/examples/setup_ruby27.sh
printf "\n\n$PWD/ruby27_snap/snap/snap_activate.sh\n" >> "$HOME/.bashrc"
```
