# Using WireGuard as VPN in QubesOS

Based on https://www.scaleway.com/en/docs/installing-wireguard-vpn-linux/

To use this guide you need VPS to use as VPN server.

Use Debian 10 on both server and client.

## On both server and client

In Qubes, do the following steps in TemplateVM (debian-10).

If needed, enable buster-backports:

```
$ echo 'deb http://deb.debian.org/debian buster-backports main' | sudo tee /etc/apt/sources.list.d/buster-backports.list
$ sudo apt-get update
```

If needed, install kernel headers:

```
$ sudo apt-get install linux-headers-amd64
```

Install WireGuard:

```
$ sudo apt-get install wireguard resolvconf
```

Make sure kernel module was installed:

```
$ sudo modprobe wireguard
$ echo $?
0
```

In Qubes, shutdown `debian-10` TemplateVM and do the following steps
in ProxyVM `sys-wireguard` based on `debian-10`. On the server, continue
in the same terminal.

Generating Public and Private Keys

```
# mkdir -p /etc/wireguard/keys
# cd /etc/wireguard/keys
# umask 077
# wg genkey | tee privatekey | wg pubkey > publickey
```

## On server

Create the file `/etc/wireguard/wg0.conf` with the following content:

```
[Interface]
PrivateKey = <private key of the server>
Address = 192.168.66.1/32
ListenPort = <random port for server>
PostUp = sysctl -w net.ipv4.ip_forward=1; iptables -A FORWARD -i %i -o %i -j DROP; iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -o %i -j DROP; iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <public key of the client>
AllowedIPs = 192.168.66.2/32

<add more clients if needed>
```

Run:

```
$ sudo wg-quick up wg0
```

You can also enable the start of WireGuard on server at boot time with the following command:

```
$ sudo systemctl enable wg-quick@wg0.service
```

## On client

Create the file `/home/user/wg0.conf` with the following content:

```
[Interface]
PrivateKey = <private key of the client>
Address = 192.168.66.2/32
DNS = 1.1.1.1
PostUp = iptables -t nat -I PREROUTING 1 -p udp -m udp --dport 53 -j DNAT --to-destination 1.1.1.1; iptables -t nat -I POSTROUTING 3 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

[Peer]
PublicKey = <public key of the client>
Endpoint = <public ip of server>:<public port of server>
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

Run:

```
$ sudo wg-quick up /home/user/wg0.conf
```

It should work at this point.

Add the following to `/rw/config/rc.local`:

```
wg-quick up /home/user/wg0.conf
```

Then `chmod +x /rw/config/rc.local`

Then go to Qubes firewall settings and limit outgoing connections to UDP `<public ip of server>:<public port of server>`.
Then do to dom0 console and use `qvm-firewall` command to remove unneeded exceptions for ICMP and DNS:

```
$ qvm-firewall sys-wireguard
... 4 rules, including unwanted DNS and ICMP rules ...
$ qvm-firewall sys-wireguard del --rule-no 1
$ qvm-firewall sys-wireguard del --rule-no 1
$ qvm-firewall sys-wireguard
... 2 rules ...
```

Make sure it now has only the server rule and then DROP.

## On Android/iOS

You can use wireguard on Android or iOS devices.

Android: https://play.google.com/store/apps/details?id=com.wireguard.android&hl=fr

iOS: https://apps.apple.com/us/app/wireguard/id1441195209?ls=1

In the app, select `Create from scratch` and configure it the same way you did
in sys-wireguard. The form has the same fields as the file.
