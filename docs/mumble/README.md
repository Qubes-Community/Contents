# Exposing Mumble server running in Qubes using Wireguard

To secure communications over Mumble, you should control the machine on which
the Mumble server is running. You can run the server locally and expose it
to the world through VPS using wireguard.

You need to setup Wireguard on your VPS and locally first.
See [the guide][wireguard]. Create a separate qube for Mumble server
and do local part of the guide in it.

Let's say your `mumble` qube has Wireguard IP 192.168.66.10 and
your VPS has external IP 1.2.3.4 and network interface eth0.
Mumble server (murmurd) is running on port 64738 locally, but let's say
you want to expose it at port 1.2.3.4:3333.

## Port forwarding

On VPS run the following:

```
# iptables -t nat -A PREROUTING -i eth0 -p udp -m udp --dport 3333 -j DNAT --to-destination 192.168.66.10:64738
# iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport 3333 -j DNAT --to-destination 192.168.66.10:64738
```

Make sure to forward both UDP and TCP. It won't work without TCP and
it will work slower without UDP.

In `mumble` qube:

```
sudo iptables -I INPUT 1 -p tcp -m tcp --dport 64738 -j ACCEPT
sudo iptables -I INPUT 1 -p udp -m udp --dport 64738 -j ACCEPT
```

## Install Mumble server

In `mumble` qube:

```
sudo apt-get install -y mumble-server
```

You can configure it using `sudo dpkg-reconfigure mumble-server` or
set password in `/etc/mumble-server.ini` (variable `serverpassword`) and
run `sudo service mumble-server restart`.

Then connect from all Mumble clients through endpoint 1.2.3.4:3333.
It should work at this point.

## Making the server persistent

Qubes removes all system files when a qube is restarted. If you install
Mumble server from scratch every time, it won't remember any configuration,
rooms, registered users, etc. Also clients will show a warning about new key.

So you should either make the qube standalone or use the following trick.

All the files you need to preserve are the following:

 * /etc/mumble-server.ini
 * /var/lib/mumble-server/mumble-server.sqlite

Finish configuration and connect from all expected clients and then stop the server:

```
$ sudo service mumble-server stop
```

and save the files in home directory:

```
$ sudo cp /etc/mumble-server.ini /var/lib/mumble-server/mumble-server.sqlite /home/user
```

Now you can restart the qube.
After that you can run the following script to start the server:

```
set -x

sudo apt-get install -y mumble-server
sudo service mumble-server stop
sudo cp /home/user/mumble-server.ini /etc/mumble-server.ini
sudo cp /home/user/mumble-server.sqlite /var/lib/mumble-server/mumble-server.sqlite
sudo service mumble-server start
sudo iptables -I INPUT 1 -p tcp -m tcp --dport 64738 -j ACCEPT
sudo iptables -I INPUT 1 -p udp -m udp --dport 64738 -j ACCEPT
```

[wireguard]: ../wireguard
