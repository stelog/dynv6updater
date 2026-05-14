#!/usr/bin/env sh

# Run as sudo

cp ./dynv6.service /usr/local/lib/systemd/system/
cp ./dynv6.timer /usr/local/lib/systemd/system/
cp ./dynv6.env /usr/local/lib/systemd/system/
cp ./dynv6.sh /usr/local/bin/

systemctl daemon-reload
systemctl enable dynv6.timer
