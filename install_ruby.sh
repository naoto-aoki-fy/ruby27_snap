#!/bin/sh

apt install squashfs-tools

./download-snap.sh ruby 2.7/stable

unsquashfs ruby_308.snap.snap -d /opt/ruby27-snap

mkdir -p /snap/core20/current/lib64
ln -s /lib64/ld-linux-x86-64.so.2 /snap/core20/current/lib64/ld-linux-x86-64.so.2