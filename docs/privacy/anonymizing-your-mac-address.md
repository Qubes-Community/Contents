
Anonymizing your MAC address
============================

Although the MAC address is not the only metadata broadcast by network hardware, changing your hardware's default [MAC Address](https://en.wikipedia.org/wiki/MAC_address) could be [an important step in protecting privacy](https://tails.boum.org/contribute/design/MAC_address/#index1h1).

Qubes OS 4.1 and later already anonymize all Wi-Fi MAC addresses [by default](https://github.com/QubesOS/qubes-core-agent-linux/blob/master/network/nm-31-randomize-mac.conf) - they change during every Wifi session.
So there is **no need** to apply any of the instructions below if you're only interested in Wi-Fi connections. Users requiring Ethernet MAC address anonymization may want to read on.

## Randomize a single connection

Right click on the Network Manager icon of your NetVM in the tray and click 'Edit Connections...'.

Select the connection to randomize and click Edit.

Select the "Cloned MAC Address" drop-down list and pick either 'Random" or "Stable'.
'Stable' will generate a random address that persists until reboot, while 'Random' will generate an address each time a link goes up.
![Edit Connection](/attachment/wiki/RandomizeMAC/networkmanager-mac-random.png)

Save the change and reconnect the connection (click on Network Manager tray icon and click "Disconnect" under the connection, it should automatically reconnect).

## Randomize all Ethernet and Wi-Fi connections

These steps should be done inside the template of the NetVM to change as it relies on creating a config file that would otherwise be deleted after a reboot due to the nature of AppVMs.

Write the settings to a new file in the `/etc/NetworkManager/conf.d/` directory, such as `50-macrandomize.conf`.
The following example enables Wi-Fi and Ethernet MAC address randomization while scanning (not connected), and uses a randomly generated but persistent MAC address for each individual Wi-Fi and Ethernet connection profile.
It was inspired by the [official NetworkManager example](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/examples/nm-conf.d/30-anon.conf).

~~~
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=stable
ethernet.cloned-mac-address=stable
connection.stable-id=${CONNECTION}/${BOOT}

#the below settings is optional (see the explanations below)
ipv6.ip6-privacy=2
~~~

* `cloned-mac-address=stable` in combination with `connection.stable-id=${CONNECTION}/${BOOT}` generates a random MAC address that persists until reboot. You could use `connection.stable-id=random` instead, which generates a random MAC address each time a link goes up.
* `ipv6.ip6-privacy=2` will cause multiple random IPv6 addresses to be used during every session (cf. [RFC 4941](https://datatracker.ietf.org/doc/html/rfc4941)). If you want to use a fixed IPv6 address based on the already random MAC address, choose `ipv6.ip6-privacy=0`. Leaving this setting at the default is not recommended as it is basically undefined.

Also make sure that you have `addr-gen-mode=stable-privacy` in the `[ipv6]` section of your `/rw/config/NM-system-connections/*.nmconnection` files as this setting can only be set per connection.

To see all the available configuration options, refer to the man page: `man nm-settings`

You can check the MAC address currently in use by looking at the status pages of your router device(s), or inside the NetVM with the command `sudo ip link show`.

## Anonymize your hostname

DHCP requests _may_ also leak your hostname to your LAN. Since your hostname is usually `sys-net`, other network users can easily spot that you're using Qubes OS.

Unfortunately `NetworkManager` currently doesn't provide an option to disable that leak globally ([NetworkManager bug 584](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/584)).

However the `NetworkManager` versions as of Qubes OS 4.1 were found to not leak the hostname as long as the file `/etc/hostname` does **not** exist. This behaviour may be subject to change in future `NetworkManager` versions though.
So please always double check whether your hostname is leaked or not on e.g. your home router, via `wireshark` or `tcpdump`.

If you want to decide per connection, `NetworkManager` provides an option to not send the hostname:  
Edit the saved connection files at `/rw/config/NM-system-connections/*.nmconnection` and add the `dhcp-send-hostname=false` line to both the `[ipv4]` and the `[ipv6]` section.
