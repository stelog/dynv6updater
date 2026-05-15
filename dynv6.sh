#!/bin/sh -e

# Dyn DNS update script for dynv6.com.
# Script is based on script found at  https://gist.github.com/corny/7a07f5ac901844bd20c9
# Changes made to update at least the IPV4 address even if there is no IPV6 address available.
#
# Required tools: ip, grep, sed, curl or wget
# Usage:
#   token=<your-authentication-token>
#   device=<network-interface> # optional, e.g. eth0, wlan0, etc.
#   hostname=<your-hostname.dynv6.com>
#

hostname=$1
device=$2
token=$3
file_ipv6=/tmp/${hostname}.addr6
file_ipv4=/tmp/${hostname}.addr4

[ -e $file_ipv6 ] && old_ipv6=`cat $file_ipv6`
[ -e $file_ipv4 ] && old_ipv4=`cat $file_ipv4`

if [ -z "$hostname" -o -z "$token" ]; then
  echo "Usage: token=<your-authentication-token> [netmask=64] $0 your-name.dynv6.net [device]"
  exit 1
fi

if [ -z "$netmask" ]; then
  # netmask=128
  netmask=64
fi

if [ -n "$device" ]; then
  device="dev $device"
fi

if [ -e /usr/bin/curl ]; then
  bin="curl -fsS"
else
  echo "curl not found."
  exit 1
fi

# Get only the global unicast address, ignore fd00::/8 (ULA) and fe80::/10 (link-local)
#address_ipv6=$(ip -6 addr list scope global $device | grep -v " fd" | sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1)
#address_ipv6=$(ip -6 addr list scope global dynamic $device | grep -Po 'inet6 \K[0-9a-fA-F:\/]+' | head -n1 | tr -d '\n')
address_ipv6=$(ip -6 addr list scope global dynamic enp2s0 | grep -v fd|grep -Po 'inet6 \K[0-9a-fA-F:\/]+' | head -n1 | tr -d '\n')
address_ipv4=$(curl -s http://checkip4.spdyn.de)

echo "Current IPv6 address: $address_ipv6"
echo "Current IPv4 address: $address_ipv4"

update_ipv6=true
update_ipv4=true
if [ -z "$address_ipv6" ]; then
  echo "no IPv6 address found"
  update_ipv6=false
fi

if [ -z "$address_ipv4" ]; then
  echo "no IPv4 address found"
  update_ipv4=false
fi

# address with netmask
#current_ipv6=$address_ipv6/$netmask
current_ipv6=$address_ipv6
echo "Current IPv6 address with netmask: $current_ipv6"
echo "Old IPv6 address: $old_ipv6"
if [ "$old_ipv6" = "$current_ipv6" ]; then
  echo "IPv6 addresses unchanged"
  update_ipv6=false
fi


if [ "$old_ipv4" = "$address_ipv4" ]; then
  echo "IPv4 addresses unchanged"
  update_ipv4=false
fi

# Update if at least one address has changed
if [ "$update_ipv6" = true ]; then
  echo "http://dynv6.com/api/update?hostname=$hostname&ipv6=$current_ipv6&token=$token"
  $bin "http://dynv6.com/api/update?hostname=$hostname&ipv6=$current_ipv6&token=$token"
  echo ""
fi

if [ "$update_ipv4" = true ]; then
  echo "http://dynv6.com/api/update?hostname=$hostname&ipv4=$address_ipv4&token=$token"
  $bin "http://dynv6.com/api/update?hostname=$hostname&ipv4=$address_ipv4&token=$token"
  echo ""
fi

# save current address
echo $current_ipv6 > $file_ipv6
echo $address_ipv4 > $file_ipv4
exit 0
