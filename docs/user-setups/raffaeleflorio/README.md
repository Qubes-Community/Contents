# User setup / @raffaeleflorio

## TemplateVMs and VMs
The following TemplateVMs are really generic. I didn't include any specialized TemplateVMs (e.g. those used for development).

### TemplateVM fedora-28-minimal
It's used only as a base for other TemplateVM.

### TemplateVM fedora-28-mini
A clone of fedora-28-minimal with:
```
qubes-core-agent-nautilus
qubes-core-agent-networking
qubes-core-agent-network-manager
qubes-core-agent-dom0-updates
network-manager-applet
dejavu-sans-fonts
notification-daemon
qubes-usb-proxy
qubes-input-proxy-sender
qubes-img-converter
qubes-pdf-converter
less
psmisc
pciutils
keepassxc
openssl
qubes-gpg-split
NetworkManager-wifi
wireless-tools
openssh-clients
nmap-ncat
oathtool
vim-common
```

Template of:
- fedora-28-mini-dvm: template for DispVMs
- sys-net: DispVM based on fedora-28-mini-dvm
- sys-usb: DispVM based on fedora-28-mini-dvm
- sys-sd: DispVM based on fedora-28-mini-dvm
- sys-firewall: DispVM based on fedora-28-mini-dvm
- vault: offline; password manager; totp generation
- *VMs used as split-{gpg,ssh} backend (e.g. work-keys)*: offline; management of a minimal set of (sub)keys
- *VMs used as data container (e.g. backup)*: offline

Notes:
- [split gpg](https://www.qubes-os.org/doc/split-gpg/)
- [split gpg advanced setup](https://www.qubes-os.org/doc/split-gpg/#advanced-using-split-gpg-with-subkeys)
- [split ssh](https://github.com/henn/qubes-app-split-ssh)

### TemplateVM fedora-28-net
A clone of fedora-28-mini with:
```
firefox
thunderbird
thunderbird-qubes
pulseaudio-qubes
mozilla-https-everywhere
mozilla-privacy-badger
```

Template of:
- dvm-net: template for DispVMs
- dispNet: DispVM based on dvm-net
- *VMs that needs a minimal Firefox and/or Thunderbird (e.g. work)*: firewalled; qubes-url-redirector; custom Firefox preferences

Notes:
- [qubes-url-redirector](https://github.com/raffaeleflorio/qubes-url-redirector)
- [Qubes community docs about link/files opening](https://github.com/Qubes-Community/Contents/blob/master/docs/common-tasks/opening-urls-in-vms.md)

### TemplateVM fedora-28-heavy
A clone of fedora-28-net with:
```
vlc
libreoffice
gimp
whois
bzip2
bind-utils
emacs
p7zip
java-1.8.0-openjdk
unar
unzip
galculator
polkit
qubes-core-agent-passwordless-root
man-pages
man
git
glibc-langpack-en
gnome-terminal
qubes-vm-recommended
tree
bash-completion
chromium
python2-jwt
```

Template of:
- dvm-heavy-offline: offline; template for DispVMs; used to handle every file in every other VMs
- dispHeavyOffline: DispVM based on dvm-heavy-offline
- dvm-heavy-online: template for DispVMs;
- dispHeavyOnline: DispVM based on dvm-heavy-online

### TemplateVM whonix-ws-14
- dvm-anon

Notes:
- [Whonix info 1](https://www.qubes-os.org/doc/whonix)
- [Whonix info 2](https://www.whonix.org/wiki/Qubes)

### TemplateVM whonix-gw-14
- sys-whonix