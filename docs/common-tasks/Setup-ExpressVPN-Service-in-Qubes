How to use ExpressVPN as ProxyVM with Qubes 4
=============================================

This Howto describes how you can use ExpressVPN with Qubes to run all traffic through a VPN Proxy-VM.
Running a VPN is an important step to improve privacy when browsing the web.

> Without a VPN, third parties can see your internet traffic.
> Your ISP can monitor your activity and share it with other organizations.
> Governments can use your data to restrict your access to content, 
> and corporations can exercise price discrimination against you.
> And you’re vulnerable to cybercrime and snooping,
> especially if you use public Wi-Fi.

Taken from [ExpressVPN - Browse Anonymously](https://www.expressvpn.com/what-is-vpn/browse-anonymously)

Using a VPN provider like (for example) ExpressVPN will help beeing moreanonymous online and keep everyone else out of your personal affairs.

Info: Using a VPN provider will cost you money and this is for a good reason.
Someone needs to pay for bandwith / infrastructure / support ... and if a service doesn't cost you money it is very likely that you will pay this service with some other kind of currency, likely this your data and metadata which is collecting using those kind of services.

## About ExpressVPN
If you decide to use ExpressVPN I would be happy if you use this [ExpressVPN Referal link](https://www.expressrefer.com/refer-friend?referrer_id=25410731&utm_campaign=referrals&utm_medium=copy_link&utm_source=referral_dashboard), which will give you and also me 30 free days of usage.

You can try out ExpressVPN for one month or you can subscribe for a year, which will costs less.
 + monthly payment: $12.95 per month
 + yearly payment: $8.32 per month

## Why a dedicated Howto?
ExpressVPN is offering very good documentation how to setup and use its services for various platforms.
Unfortunately their [ExpressVPN Qubes Howto](https://www.expressvpn.com/de/support/vpn-setup/app-for-qubes-os/) is recommending their own ExpressVPN Linux Client which should be installed in sys-net.
I think this is not how it should be done, as having an own ExpressVPN-AppVM which also not using any special packages but just OpenVPN is more flexibel and aligns better to the idea how Qubes should be used.
You can then easily decide which AppVMs will put their traffix into the VPN and which AppVMs not.
You can (of course) also choose to use VPN on all AppVMs by simple putting the VPN AppVM between sys-net and sys-firewall.

------------
This howto will cover:
- Creating a new vpn-template which is based on fedora-28-minimal (named: t-fedora-28-vpn)
- Create an Proxy-AppVM (named: sys-vpn)
- Configure ExpressVPN in the Proxy-AppVM

If you run into any problems with this Howto, do not hesitate to contact me.
The benefit of this setup is:
you can decide which AppVMs should run their traffic through ExpressVPN,
simple by setting their netvm to sys-vpn.

------------
## 1. Creating a new VPN-Template

Install fedora-28-minimal template in dom0
```sh
sudo qubes-dom0-update qubes-template-fedora-28-minimal
```

Clone this template to a new template, which will be used for the VPN AppVM later
Hint: keep the original templates as baseline templates if you run into problems
```
qvm-clone fedora-28-minimal t-fedora-28-vpn
```
Updates packages in the new template and install additional packages
See also: https://www.qubes.org/doc/templates/fedora-minimal
          Section: Package Table for Qubes 4
```
qvm-run --auto --user root t-fedora-28-vpn "xterm -hold -e 'dnf -y update && \
  dnf -y install qubes-core-agent-qrexec qubes-core-agent-systemd qubes-core-agent-networking polkit \
  qubes-core-agent-network-manager notification-daemon qubes-core-agent-dom0-updates  \
  network-manager-applet nano iputils NetworkManager-openvpn NetworkManager-openvpn-gnome && \
  echo ... Everything completed! Shutdown Template'"
qvm-shutdown t-fedora-28-vpn
```

------------
## 2. Build and AppVM
Create a new AppVM from this template
```
qvm-create --template t-fedora-28-vpn --label orange sys-vpn
```

Set this VM as netvm
```
qvm-prefs --set sys-vpn provides_network True
```

Set sys-net as NetVM (sys-firewall will not work)
```
qvm-prefs --set sys-vpn netvm sys-net
```

Enable Network-Manager to get nm-applet to configure/launch/monitor the VPN-connection

```
qvm-service --enable sys-vpn network-manager
```

Start AppVM as root user
```
qvm-run --user root sys-vpn xterm
```

------------
## 3. Configure ExpressVPN in the AppVM
Download the OpenVPN configuration file from ExpressVPN
- Launch a disposable VM or your preferred AppVM to browse the Web
- Login into ExpressVPN and download the OpenVPN configuration package
- Go to the Setup page and choose manual config
- https://www.expressvpn.com/setup#manual
- Download the OpenVPN configuration file for your preferred location
- Click Save File and then open the downloads directory
- Right Click the file and choose "Copy to Other AppVM..."
  copy the file to the AppVM (not the Template)

Configure ExpressVPN
- Import the OpenVPN config file via left click in the AppVM Network Manager Applet
- Choose "VPN Connections" > "Add a VPN Connection..."
- Then choose "Import a saved VPN configuration" and [Create]
- Import  the downloaded OpenVPN configuration file (QubesIncoming/...)
- Beautify the Name, like ExpressVPN-<Locationname>
- Copy & Paste the Username and Password from your ExpressVPN page into correct fields
  (User key password can be left empty)
- Important: Click on the right Icon in the password field and choose:
- (X) Store the passwords for all users
- Save the dialog

Try to connect via ExpressVPN using the Network Manager applet
If it doesn't work try to reboot the AppVM
```
qvm-shutdown --wait sys-vpn && qvm-start sys-vpn
```

To use the VPN connection automatically, use Network Manager CLI (nmcli) during boot when a network connection is available:
Hint: for some reason enabling autoconnection to the VPN via network manager will not survive reboots of the AppVM
Therefore we apply a fix as described in the Qubes Docs
Link: https://www.qubes-os.org/doc/vpn/
rc.local will be run after boot, it will wait until ping to 1.1.1.1 will succeed and then launch the VPN
```
qvm-run --user root sys-vpn "xterm -hold -e 'vi /rw/config/rc.local'"
```

Hit i to switch to insert mode in the vi editor
Add the following 6 lines at the end of the file:
```
# Automatically connect to the VPN once Internet is up
# https://www.qubes-os.org/doc/vpn/
while ! ping -c 1 -W 1 1.1.1.1; do
   sleep 1
done
nmcli connection up ExpressVPN-<Location>
```

ExpressVPN-<Location> has to match the name of the OpenVPN connection.
In my case for example ExpressVPN-Frankfurt

To save the changes, hit Escape-Key and then :wq
(:wq = Write file, then quit)

In case that the VPN connection breaks you want to make sure that not data is leaked.
```
qvm-run --user root sys-vpn "xterm -hold -e 'vi /rw/config/qubes-firewall-user-script'"
```

Add those 4 lines (i to enable insert-mode):
```
# Block forwarding of connections through upstream network device
# (in case the vpn tunnel breaks)
iptables -I FORWARD -o eth0 -j DROP
iptables -I FORWARD -i eth0 -j DROP
```
Save the file changes again (Escape, then :wq)

Reboot the AppVM and look if autoconnection is working
```
qvm-shutdown --wait sys-vpn && qvm-start sys-vpn
```

You can now use this AppVM as netvm for all Qubes which should run over the VPN connection:
```
qvm-prefs --set YOUROTHERAPPVM netvm sys-vpn
```

Run all (!) traffic through the ExpressVPN
To run all traffic through ExpressVPN it is enough to set the netvm of sys-forewall to sys-vpn.
```
qvm-prefs --set sys-firewall netvm sys-vpn
```
 + Your AppVMs --> sys-firewall --> sys-vpn --> sys-net
 + Whoonix Workstation --> sys-whonix --> sys-firewall --> sys-vpn --> sys-net

------------
## 4. Test if VPN-connection is working
make sure that the VPN is working by running the DNS Leakage test:
https://www.expressvpn.com/de/dns-leak-test

If you terminate the VPN connection all AppVMs should not be able to connect to the web (added DROP-rules above)
