
How To make a VPN Gateway in Qubes
==================================


<b>Note:</b> If you seek to enhance your privacy, you may also wish to consider [Whonix](https://qubes-os.org/doc/whonix/).
You should also be aware of [the potential risks of VPNs](https://www.whonix.org/wiki/Tunnels/Introduction).

Although setting up a VPN connection is not by itself Qubes specific, Qubes includes a number of tools that can make the client-side setup of your VPN more versatile and secure. Please refer to your guest OS and VPN service documentation when considering the specific steps and parameters for your connection(s); The relevant documentation for the Qubes default guest OS (Fedora) is [Establishing a VPN Connection.](https://docs.fedoraproject.org/en-US/Fedora/23/html/Networking_Guide/sec-Establishing_a_VPN_Connection.html)

This document provides a basic overview. See also [Tasket's VPN page](https://github.com/tasket/Qubes-vpn-support).

1. Set up a network infrastructure such as:
```
                                             -------- your VPN client VM 1
sys-net -- sys-fw -- sys-vpn -- sys-fw-vpn --|
                                             -------- your VPN client VM 2 etc.
```
Use `qvm-prefs netvm` and `qvm-prefs provides_network` for that.

2. IMPORTANT: Configure your Qubes Os firewall to only allow traffic from sys-vpn to your VPN provider.
I.e. `qvm-firewall sys-vpn --raw` should show something like
```
action=accept proto=tcp dst4=[VPN IP]/32 dstports=[port]-[port]
```
in the end. Use `qvm-firewall` and not the GUI as the GUI will allow e.g. DNS & pings by default IIRC (you need to remove those GUI rules).

If you leave out this step or get it wrong, VPN leaks may be possible.
For testing purposes you could skip this step and implement it after step 3 though.

3. Inside sys-vpn at `/rw/config/rc.local` (autostart file) start your VPN client, e.g. `openvpn` with whatever config you need.
If DNS doesn't work after step 3, you might have to add the following lines to `/rw/config/rc.local` inside `sys-vpn`:
```
#[your openvpn stuff here]
echo "nameserver [your DNS server]" > /etc/resolv.conf
/usr/lib/qubes/qubes-setup-dnat-to-ns 
```

Troubleshooting
---------------

See the [VPN Troubleshooting](https://www.qubes-os.org/doc/vpn-troubleshooting/) guide for tips on how to fix common VPN issues. 
