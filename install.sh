#!/usr/bin/env sh

set -e

# Run as sudo
[ "$(id -u)" -eq 0 ] || { echo "Run as root"; exit 1; }

cp ./dynv6.service /usr/local/lib/systemd/system/
cp ./dynv6.timer /usr/local/lib/systemd/system/
install -m 600 -o root -g root ./dynv6.env /usr/local/lib/systemd/system/dynv6.env
cp ./dynv6.sh /usr/local/bin/

systemctl daemon-reload
systemctl enable --now dynv6.timer
