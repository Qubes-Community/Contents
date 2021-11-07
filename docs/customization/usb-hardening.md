
# USB Hardening

Qubes OS provides means to attach [USB devices to a qube](https://www.qubes-os.org/doc/how-to-use-usb-devices/)
and in general recommends using an [USB qube](https://www.qubes-os.org/doc/usb-qubes/). The Qubes OS
documentation also highlights the [security implications](https://www.qubes-os.org/doc/device-handling-security/).

Nonetheless users may want to

- harden their qubes with attached USB devices against USB attacks.
- harden `dom0` against USB attacks, if they assigned some USB ports to `dom0`, e.g. for USB keyboard or mice
  to avoid the [security pitfalls](https://www.qubes-os.org/doc/device-handling-security/#usb-security) of
  assigning them to an [USB qube](https://www.qubes-os.org/doc/usb-qubes/).

[USBGuard](https://usbguard.github.io/) is a tool that can be used for such purposes.

## USBGuard

### Security Considerations

By default the Linux kernel will attempt to recognize plugged in USB devices based on their device ID
and load the kernel drivers matching that device ID. If e.g. those device drivers have security issues,
an attacker can exploit those and take control of the qube or in the case of `dom0` the entire system.

[USBGuard](https://usbguard.github.io/) uses kernel interfaces to whitelist USB devices based on their
provided interfaces and device IDs. Keep in mind though that rogue USB devices can easily forge device IDs
and/or launch a [brute-force attack](https://en.wikipedia.org/wiki/Brute-force_attack) on an unknown
whitelisted device ID.

Rogue devices however cannot exploit interfaces/kernel drivers that are not made available to them due to
[USBGuard](https://usbguard.github.io/). This is where hardening may make sense.

### Installation

[USBGuard](https://usbguard.github.io/) should be available from the default repositories of your
[Qubes templates](https://www.qubes-os.org/doc/templates/).

For dom0, you can install it via
```
sudo qubes-dom0-update usbguard
```

### `dom0` Example Setup

_(The below guide only works with Qubes OS 4.1 or higher.)_

The below setup is intended for users with USB ports that are connected to `dom0`. It doesn't whitelist
any devices (users may want to add their device/interface combinations for convenience), but assumes the
following:

1. All USB devices attached at boot time are allowed, all others rejected.
2. The user may employ a small script to allow USB devices attached during the next minute or so.

#### USBGuard Configuration

To achieve that, edit the USBGuard configuration at `/etc/usbguard/usbguard-daemon.conf` to include the
following lines:
```
#reject all devices by default
ImplicitPolicyTarget=reject

#allow all devices that are available at boot time
PresentDevicePolicy=allow
PresentControllerPolicy=allow
```

The policy itself at `/etc/usbguard/rules.conf` would have to look as follows:
```
############ REJECT #################

#only let certain interfaces pass to our default policy and block all others
#generate via bash: seq 0 255 | while read -r i ; do printf '%.2X:*:* ' "$i" ; done
#NOTE: reject *:* with-interface none-of { allowed ones } wouldn't work precisely as a malicious device could just add an interface of the allowed types _in addition_ to its unwanted interface types to pass
#
#only allowed:
#01: audio
#03: HID
#08: mass storage
#09: hub
#0B: smart card
reject *:* with-interface one-of { 00:*:* 02:*:* 04:*:* 05:*:* 06:*:* 07:*:* 0A:*:* 0C:*:* 0D:*:* 0E:*:* 0F:*:* 10:*:* 11:*:* 12:*:* 13:*:* 14:*:* 15:*:* 16:*:* 17:*:* 18:*:* 19:*:* 1A:*:* 1B:*:* 1C:*:* 1D:*:* 1E:*:* 1F:*:* 20:*:* 21:*:* 22:*:* 23:*:* 24:*:* 25:*:* 26:*:* 27:*:* 28:*:* 29:*:* 2A:*:* 2B:*:* 2C:*:* 2D:*:* 2E:*:* 2F:*:* 30:*:* 31:*:* 32:*:* 33:*:* 34:*:* 35:*:* 36:*:* 37:*:* 38:*:* 39:*:* 3A:*:* 3B:*:* 3C:*:* 3D:*:* 3E:*:* 3F:*:* 40:*:* 41:*:* 42:*:* 43:*:* 44:*:* 45:*:* 46:*:* 47:*:* 48:*:* 49:*:* 4A:*:* 4B:*:* 4C:*:* 4D:*:* 4E:*:* 4F:*:* 50:*:* 51:*:* 52:*:* 53:*:* 54:*:* 55:*:* 56:*:* 57:*:* 58:*:* 59:*:* 5A:*:* 5B:*:* 5C:*:* 5D:*:* 5E:*:* 5F:*:* 60:*:* 61:*:* 62:*:* 63:*:* 64:*:* 65:*:* 66:*:* 67:*:* 68:*:* 69:*:* 6A:*:* 6B:*:* 6C:*:* 6D:*:* 6E:*:* 6F:*:* 70:*:* 71:*:* 72:*:* 73:*:* 74:*:* 75:*:* 76:*:* 77:*:* 78:*:* 79:*:* 7A:*:* 7B:*:* 7C:*:* 7D:*:* 7E:*:* 7F:*:* 80:*:* 81:*:* 82:*:* 83:*:* 84:*:* 85:*:* 86:*:* 87:*:* 88:*:* 89:*:* 8A:*:* 8B:*:* 8C:*:* 8D:*:* 8E:*:* 8F:*:* 90:*:* 91:*:* 92:*:* 93:*:* 94:*:* 95:*:* 96:*:* 97:*:* 98:*:* 99:*:* 9A:*:* 9B:*:* 9C:*:* 9D:*:* 9E:*:* 9F:*:* A0:*:* A1:*:* A2:*:* A3:*:* A4:*:* A5:*:* A6:*:* A7:*:* A8:*:* A9:*:* AA:*:* AB:*:* AC:*:* AD:*:* AE:*:* AF:*:* B0:*:* B1:*:* B2:*:* B3:*:* B4:*:* B5:*:* B6:*:* B7:*:* B8:*:* B9:*:* BA:*:* BB:*:* BC:*:* BD:*:* BE:*:* BF:*:* C0:*:* C1:*:* C2:*:* C3:*:* C4:*:* C5:*:* C6:*:* C7:*:* C8:*:* C9:*:* CA:*:* CB:*:* CC:*:* CD:*:* CE:*:* CF:*:* D0:*:* D1:*:* D2:*:* D3:*:* D4:*:* D5:*:* D6:*:* D7:*:* D8:*:* D9:*:* DA:*:* DB:*:* DC:*:* DD:*:* DE:*:* DF:*:* E0:*:* E1:*:* E2:*:* E3:*:* E4:*:* E5:*:* E6:*:* E7:*:* E8:*:* E9:*:* EA:*:* EB:*:* EC:*:* ED:*:* EE:*:* EF:*:* F0:*:* F1:*:* F2:*:* F3:*:* F4:*:* F5:*:* F6:*:* F7:*:* F8:*:* F9:*:* FA:*:* FB:*:* FC:*:* FD:*:* FE:*:* FF:*:* }

############# ALLOW ################

# You may want to add your devices here for convenience, but it's not absolutely necessary if you use the provided script to temporarily allow new devices.

#NOTE: the one-ofs are workarounds for https://github.com/USBGuard/usbguard/issues/207
#      Since we filter out everything else above, one-of should be fine.

#USB hubs (some internal)
#allow id xxxx:xxxx with-interface one-of { 09:*:* }

#mouse & keyboard
#allow id xxxx:xxxx with-interface one-of { 03:*:* }

#external sound card
#allow id xxxx:xxxx with-interface one-of { 01:*:* }

#hard disks
#allow id xxxx:xxxx with-interface one-of { 08:*:* }

#smart cards
#allow id xxxx:xxxx with-interface one-of { 0B:*:* }

########### DEFAULT #################

#Everything connected during service startup will otherwise be allowed in this configuration.
#Everything connected later will be rejected.
```

Please note that misconfigurations to the `usbguard` configuration may make the respective USB devices
temporarily unusable on your host. The log file available at `/var/log/usbguard/usbguard.log` may help
to investigate issues.

At the end of the configuration, you may have to restart the service via `systemctl restart usbguard`.
Also make sure that it is enabled at boot time via `systemctl enable usbguard`.

#### Script to temporarily allow new devices

To temporarily allow new devices for 60 seconds, you can e.g. use the following script:

```bash
#!/bin/bash
#
# Temporarily allow new USB devices.
#
# Assumes ImplicitPolicyTarget=reject in the default configuration.
#
# Related:
# https://github.com/USBGuard/usbguard/issues/367
# https://github.com/USBGuard/usbguard/issues/436

function error {
local msg="$1"
notify-send -u critical -t 90000 "usbguard ERROR" "$msg"
>&2 echo "ERROR: $1"
exit 1
}

[ $EUID -eq 0 ] || error "This script must be run as root."

# This works from usbguard 0.75 on (only Qubes 4.1+):
policy="$(usbguard get-parameter ImplicitPolicyTarget)" || error "Failed to retrieve the current usbguard policy."
[[ "$policy" == "allow" ]] && error "Already allowing everything. No need to run."
usbguard set-parameter ImplicitPolicyTarget allow || error "Failed to execute usbguard."
notify-send -t 60000 "usbguard" "Allowing all..."

sleep 60

usbguard set-parameter ImplicitPolicyTarget "$policy" || error "Failed to set usbguard back to its old policy!"
notify-send -t 15000 "usbguard" "${policy}ing again."
```
