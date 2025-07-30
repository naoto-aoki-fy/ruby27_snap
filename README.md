# Ruby 2.7 Snap Installer

This repository contains simple scripts for installing Ruby 2.7 from a Snap package and configuring the environment to use it.

- **snap_download.sh** – Downloads a package from the Snap repository. The
  destination filename can be specified as an optional argument.
- **install_ruby.sh** – Installs Ruby 2.7 using a downloaded Snap package,
  skipping steps when files already exist and only running `apt` commands when
  required packages are missing.
- **env.sh** – Sets environment variables for running Ruby 2.7.

## Usage

1. Run `install_ruby.sh` as root to download and extract the Ruby 2.7 Snap package. If the
   `ruby27.snap` file or extracted directory already exist, those steps are skipped.
   Required packages are installed only when missing, so `apt-get update` and
   `apt-get install` are skipped if everything is already present.
2. Source `env.sh` to update the environment variables for your shell.

These scripts are experimental and assume a Linux environment with Snap and `squashfs-tools` available.
