# dynv6updater

A lightweight shell script that keeps your IPv4 and IPv6 addresses up to date at [dynv6.com](https://dynv6.com). It runs as a systemd service triggered by a timer every 5 minutes and only sends an update when an address has actually changed.

Based on [this gist](https://gist.github.com/corny/7a07f5ac901844bd20c9).

## How it works

- Detects the current public IPv4 address via `https://checkip4.spdyn.de`
- Detects the current global unicast IPv6 address on the configured network interface
- Compares both against the last known addresses stored in `/tmp`
- Calls the dynv6 HTTPS API only when something changed
- Supports updating two domains from the same host in one service run

## Requirements

- `curl`
- `ip` (iproute2)
- systemd

## Installation

1. Copy `dynv6.env.example` to `dynv6.env` and fill in your values (see [Configuration](#configuration)).

2. Run the installer as root:

   ```sh
   sudo ./install.sh
   ```

   This copies the service, timer, and env file to `/usr/local/lib/systemd/system/`, the script to `/usr/local/bin/`, and enables the timer.

### Manual installation

```sh
cp dynv6.service dynv6.timer /usr/local/lib/systemd/system/
install -m 600 -o root -g root dynv6.env /usr/local/lib/systemd/system/dynv6.env
cp dynv6.sh /usr/local/bin/
systemctl daemon-reload
systemctl enable --now dynv6.timer
```

## Configuration

Edit `dynv6.env` before installing:

```sh
DOMAIN1="your-host.dynv6.net"   # primary domain to update
DOMAIN2="your-host2.dynv6.net"  # second domain (can be the same as DOMAIN1)
INTERFACE="eth0"                 # network interface for IPv6 detection
TOKEN="your-dynv6-api-token"    # API token from dynv6.com account settings
```

The env file is installed with permissions `600` (root-readable only) to protect the API token.

If you only need one domain, set `DOMAIN2` to the same value as `DOMAIN1` or remove the second `ExecStart` line from `dynv6.service`.

## Checking status

```sh
systemctl status dynv6.timer
journalctl -u dynv6.service
```
