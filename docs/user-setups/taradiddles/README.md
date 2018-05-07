User setup / @taradiddles
=========================

Hardware
--------

Lenovo Thinkpad T450s


TemplateVMs and VMs
-------------------

(see end of doc for how to configure the templateVMs)

### TemplateVM 'fedora-minimal' ###

Custom minimal template for:

- VM 'sys-firewall'
- VM 'sys-net'
- VM 'vault': not networked; used for keepassxc (password manager) and [split gpg](https://www.qubes-os.org/doc/split-gpg/)

### TemplateVM 'fedora-medium ###

Custom default template with libreoffice, thunderbird, ...

- VM 'work': firewalled, ssh to known hosts and to mail server; used for emails/office work and storing non confidential documents.
- VM 'banking': firewalled, only a few IPs allowed; used only for e-banking
- VM 'halftrusted': used only for e-shopping
- VM 'private': not networked; used for opening and storing private documents

### TemplateVM 'fedora-heavy' ###

Larger custom template with programs from non-fedora repos (multimedia, non free, ...)

- VM 'untrusted': not networked; used for opening multimedia files, and content that is thought to be OK. See [this comment](https://github.com/Qubes-Community/Contents/issues/21#issuecomment-385189481) for the rationale behind keeping this VM isolated from Internet.
- VM 'sys-usb': firewalled, only 1 IP allowed (playing music from a NAS to a USB soundcard).
- dispVM 'dispBrowser': doc / WIP; used for casual browsing. Using with a customized firefox profile with privacy extensions and a custom `user.js` file (adapted from [here](https://github.com/pyllyukko/user.js)).
- dispVMs: used for opening content downloaded from unknown/dodgy sources and browsing sites that won't work with the restricted firefox profile of 'dispBrowser'.


DOM0 customization
------------------

### Xterm ###

Open xterm instead of xfce4-terminal: in `/etc/xdg/xfce4/helpers.rc`, set

~~~
TerminalEmulator=xterm
~~~

Xresources for xterm are in `$HOME/.Xresources`


### Power management ###

See https://github.com/taradiddles/qubes-os/tree/master/powermgnt

(not clear how much it helps with battery usage - never had the time to do proper testing; shouldn't hurt though).


### Productivity tweaks ###

Define application shortcuts with Qubes Menu -> System Tools -> Keyboard -> Application Shortcuts; for instance:

- ctrl-alt C: open a calculator in VM untrusted (`qvm-run -q -a untrusted galculator`)
- ctrl-alt X: open a popup windows (script [here](https://github.com/taradiddles/qubes-os/blob/master/popup-appmenu-r4) for opening Xterm in a given VM. Screenshot [here](https://github.com/taradiddles/qubes-os/blob/master/popup-appmenu.screenshot.jpg)).
- ctrl-alt F: ditto, but with firefox
- ctrl-alt K: open keepassxc in VM vault


VMs customization
-----------------

sys-net: since nm-applet isn't started by default in all VMs (see section below), start it with a .desktop file in `$HOME/.config/autostart` (note: can't use `rc.local` because Xorg isn't started yet when `rc.local` runs).


TemplateVMs customization
-------------------------

### fedora-minimal ###

Installed ITL's fedora-26-minimal rpm + installed the following rpms:

~~~
qubes-core-agent-passwordless-root
qubes-core-agent-networking
qubes-core-agent-network-manager
qubes-core-agent-dom0-updates
qubes-usb-proxy
network-manager-applet
polkit
less
pciutils
psmisc
NetworkManager-wifi
dejavu-sans-fonts
dejavu-sans-mono-fonts
tcpdump
telnet
wireless-tools
iwl7260-firmware
keepassxc pwgen
sharutils
rsync
qubes-gpg-split
qubes-core-agent-nautilus
bzip2
~~~

Fixes/tweaks:
- `/usr/lib/qubes-tweak`:
    - `fix-xdg`: remove autostart stuff in `/etc/xdg/autostart`; this will prevent for instance nm-applet from starting in all VMs while it's only necessary in sys-net.
    - `setxkbmap.desktop`: multiple keyboard layouts (see [this doc](https://github.com/Qubes-Community/Contents/blob/master/docs/localization/keyboard-multiple-layouts.md)).
    - `solarized.vim2`, `vimrc.add.colors`: configure vim to use the [solarized](http://ethanschoonover.com/solarized) color scheme.
    - `Xresources` and `xresources.desktop`: load Xresources at boot (can't simply use `/etc/X11/xresources` because `xinit` runs `xrdb -merge` without the preprocessor, which breaks the solarized color scheme definitions.
- `/etc/profile.d/interactive-commands.sh`: ask before rm/cp/mv'ing files


### fedora-medium ###

Cloned fedora-minimal and installed the following rpms:

~~~
tigervnc
firefox
thunderbird
tmux
proxychains
nfs-utils
encfs
gimp
libreoffice-calc libreoffice-writer libreoffice-draw libreoffice-impress
units
fuse-sshfs
p7zip
perl-Image-ExifTool
qpdf
vim-enhanced
man
glibc-langpack-en
nfs-utils
eog
evince
thunderbird-qubes
qubes-img-converter
qubes-pdf-converter
git
thunderbird-enigmail
~~~

Fixes:

~~~
set LANG=en_US.UTF-8 in /etc/locale.conf
~~~


### fedora-heavy ###

Cloned fedora-medium.

Installed the following repos:

- Google Chrome
- rpmfusion-free
- rpm-fussion-nonfree

And installed the following rpms:

~~~
calibre
nextcloud-client
ufraw
viking
java-1.8.0-openjdk
mc
google-chrome-stable
gphoto2
gvfs-mtp
gvfs-gphoto2
gvfs-fuse
simple-mtpfs
qubes-vm-recommended
whois
bind-utils
galculator
fuse-exfat
unrar
ffmpeg
mpv
qgis-python
~~~



