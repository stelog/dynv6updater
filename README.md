# dynv6updater

Script for updating IPv4 and IPv6 addresses at dynv6.com

The script is based on this script: https://gist.github.com/corny/7a07f5ac901844bd20c9

## Installation

Run install.sh as sudo.

Or install manually. Put the *.timer and *.service file to /usr/local/lib/systemd/system.
Copy the shell script to /usr/local/bin/.

Modify in the service file, dynv6.service, ExecStart from

```bash
ExecStart=/usr/local/bin/dynv6.sh <domain name> <network device> <API key dynv6.com>
```

to

```bash
ExecStart=/usr/local/bin/dynv6.sh domain.dynv6.net enp2s0 1234567890
```
