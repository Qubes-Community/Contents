# How to create a fedora 29 based sys-template

This Howto will cover how I build a template which I use for my sys-vms, like:

- sys-net
- sys-firewall
- sys-usb
- sys-vpn

While the default sys-VMs in Qubes work, I like to run my own custom build template which have less packages installed and are based on the fedora-29 minimal template.

You can just copy & paste the following content, which will setup the new template.
If you have any questions or if you have comments to improve the setup, do not hesitate to contact me.

```
template=fedora-29-minimal
systemplate=t-fedora-29-sys

# get fedora-29-minimal template
sudo qubes-dom0-update qubes-template-$template

#remove old template
qvm-kill $systemplate
qvm-remove -f $systemplate

#clone template
qvm-clone $template $systemplate
# update template
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf update -y'

# install a missing package for fedora-29-minimal
# without it, gui-apps will not start
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf install -y e2fsprogs'

# Install required packages for Sys-VMs
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install qubes-core-agent-qrexec qubes-core-agent-systemd \
  qubes-core-agent-networking polkit qubes-core-agent-network-manager \
  notification-daemon qubes-core-agent-dom0-updates qubes-usb-proxy \
  iwl6000g2a-firmware qubes-input-proxy-sender iproute iputils \
  NetworkManager-openvpn NetworkManager-openvpn-gnome \
  NetworkManager-wwan NetworkManager-wifi network-manager-applet'

# Optional packages you might want to install in the sys-template:
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install nano less pciutils xclip'

# Nice(r) Gnome-Terminal compared to xterm
qvm-run --auto --user root --pass-io --no-gui $systemplate \
  'dnf -y install gnome-terminal terminus-fonts dejavu-sans-fonts \
   dejavu-sans-mono-fonts'

# Set new template as template for sys-vms
qvm-shutdown --all --wait --timeout 120
qvm-prefs --set sys-usb template $systemplate
qvm-prefs --set sys-net template $systemplate
qvm-prefs --set sys-firewall template $systemplate
qvm-prefs --set sys-vpn template $systemplate
qvm-start sys-firewall sys-usb
```


