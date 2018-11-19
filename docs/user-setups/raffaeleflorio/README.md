# User setup / @raffaeleflorio

## Dom0
I installed in Dom0 [luks-2fa-dracut](https://github.com/raffaeleflorio/luks-2fa-dracut).

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

#### TemplateBasedVMs table

| Name | Description | RAM Usage (in MB) | Networking |
| --- | --- | --- | --- |
| fedora-28-mini-dvm | Template for DispVMs | default | offline |
| sys-net | DispVM based on fedora-28-mini-dvm | 300-500 | online |
| sys-usb | DispVM based on fedora-28-mini-dvm | 300-500 | offline |
| sys-sd | DispVM based on fedora-28-mini-dvm | 300-500 | offline |
| sys-firewall | DispVM based on fedora-28-mini-dvm | 300-500 | online |
| vault | Password manager and totp generation | 300-400 | offline |
| * | split-{gpg,ssh} backend (e.g. work-keys) with minimal set of (sub)keys | 300-400 | offline |
| * | Data container (e.g. backup)| 300-400 | offline/firewalled |

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

#### TemplateBasedVMs table

| Name | Description | RAM Usage (in MB) | Networking |
| --- | --- | --- | --- |
| dvm-net | Template for DispVMs, generally used for browsing | 400-1000 | online |
| dispNet | DispVM based on dvm-net | 400-1000 | online |
| * | Custom Firefox with qubes-url-redirector and/or Thunderbird (e.g. work)| 300-700 | firewalled |

Notes:
- [qubes-url-redirector](https://github.com/raffaeleflorio/qubes-url-redirector)
- [Qubes community docs about link/files opening](https://github.com/Qubes-Community/Contents/blob/master/docs/common-tasks/opening-urls-in-vms.md)

### TemplateVM fedora-28-heavy
A clone of fedora-28-net with:
```
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

#### TemplateBasedVMs table

| Name | Description | RAM Usage (in MB) | Networking |
| --- | --- | --- | --- |
| dvm-heavy-offline | Template for DispVMs. Handler of every file in every VM | 400-1000 | offline |
| dispHeavyOffline | DispVM based on dvm-heavy-offline | 400-1000 | offline |
| dvm-heavy-online | Template for DispVMs | 400-1000 | online |
| dispHeavyOnline | DispVM based on dvm-heavy-online | 400-1000 | online |

### TemplateVM fedora-28-media
A clone of fedora-28-heavy with:

```
vlc
ffmpeg
fuse-exfat
*eventually other rpmfusion packages*
```
#### TemplateBasedVMs table

| Name | Description | RAM Usage (in MB) | Networking |
| --- | --- | --- | --- |
| dvm-media-offline | Template for DispVMs | 400-1500 | offline |
| dvm-media-online | Template for DispVMs | 400-1500 | online |

### TemplateVM whonix-ws-14
#### TemplateBasedVMs table

| Name | Description | RAM Usage (in MB) | Networking |
| --- | --- | --- | --- |
| dvm-anon | Template for DispVMs | 400-1000 | online |

Notes:
- [Whonix info 1](https://www.qubes-os.org/doc/whonix)
- [Whonix info 2](https://www.whonix.org/wiki/Qubes)

### TemplateVM whonix-gw-14
#### TemplateBasedVMs table

| Name | Description | RAM Usage (in MB) | Networking |
| --- | --- | --- | --- |
| sys-whonix | Whonix gateway | 500-800 | online |