
Anonymizing your MAC Address
============================

Although it is not the only metadata broadcast by network hardware, changing the default [MAC Address](https://en.wikipedia.org/wiki/MAC_address) of your hardware could be [an important step in protecting privacy](https://tails.boum.org/contribute/design/MAC_address/#index1h1).

Qubes OS 4.1 and higher already anonymize all Wifi MAC addresses [by default](https://github.com/QubesOS/qubes-core-agent-linux/blob/master/network/nm-31-randomize-mac.conf) - they change during every Wifi session.
So there is **no need** to apply any of the below instructions if you're only interested in Wifi connections. Users requiring Ethernet MAC address anonymization may want to read on.

## Randomize a single connection

Right click on the Network Manager icon of your NetVM in the tray and click 'Edit Connections..'.

Select the connection to randomize and click Edit.

Select the Cloned MAC Address drop down and set to Random or Stable.
Stable will generate a random address that persists until reboot, while Random will generate an address each time a link goes up.
![Edit Connection](/attachment/wiki/RandomizeMAC/networkmanager-mac-random.png)

Save the change and reconnect the connection (click on Network Manager tray icon and click disconnect under the connection, it should automatically reconnect).

## Randomize all Ethernet and Wifi connections

These steps should be done inside a template to be used to create a NetVM as it relies on creating a config file that would otherwise be deleted after a reboot due to the nature of AppVMs.

Write the settings to a new file in the `/etc/NetworkManager/conf.d/` directory, such as `00-macrandomize.conf`.
The following example enables Wifi and Ethernet MAC address randomization while scanning (not connected), and uses a randomly generated but persistent MAC address for each individual Wifi and Ethernet connection profile.

~~~
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=stable
ethernet.cloned-mac-address=stable
connection.stable-id=${CONNECTION}/${BOOT}
#use random IPv6 addresses per session / don't leak MAC via IPv6 (cf. RFC 4941):
ipv6.ip6-privacy=2
~~~

* `stable` in combination with `${CONNECTION}/${BOOT}` generates a random address that persists until reboot.
* `random` generates a random address each time a link goes up.

To see all the available configuration options, refer to the man page: `man nm-settings`

Next, create a new NetVM using the edited template and assign network devices to it.

Finally, shutdown all VMs and change the settings of sys-firewall, etc. to use the new NetVM.

You can check the MAC address currently in use by looking at the status pages of your router device(s), or inside the NetVM with the command `sudo ip link show`.

## Anonymize your hostname

DHCP requests _may_ also leak your hostname to your LAN. Since your hostname is usually `sys-net`, other network users can easily spot that you're using Qubes OS.

Unfortunately `NetworkManager` currently doesn't provide an option to disable that leak globally ([Network Manager bug 584](https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/issues/584)). However the below alternatives exist.

### Prevent hostname sending

`NetworkManager` can be configured to use `dhclient` for DHCP requests. `dhclient` has options to prevent the hostname from being sent. To do that, add a file to your `sys-net` template (usually the Fedora or Debian base template) named e.g. `/etc/NetworkManager/conf.d/dhclient.conf` with the following content:  
```
[main]
dhcp=dhclient
```
Afterwards edit `/etc/dhcp/dhclient.conf` and remove or comment out the line starting with `send host-name`. If the file does not exist, you may be fine already.
In any case it makes sense to double check your results on e.g. your home router, `wireshark` or `tcpdump`.

If you want to decide per connection, `NetworkManager` also provides an option to not send the hostname:  
Edit the saved connection files at `/rw/config/NM-system-connections/*.nmconnection` and add the `dhcp-send-hostname=false` line to both the `[ipv4]` and the `[ipv6]` section.
