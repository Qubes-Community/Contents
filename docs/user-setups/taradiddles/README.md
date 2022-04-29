User setup / @taradiddles
=========================

Hardware
--------

Lenovo Thinkpad T450s


TemplateVMs and qubes
---------------------

Philosophy: use a few custom templates rather than a large one. Pro: minimize attack surface. Cons: more work to set up, and more time spent updating (for the latter, setting up a caching proxy in your LAN or [even in a qube](https://github.com/rustybird/qubes-updates-cache) will speed up things).

### TemplateVM 'fedora-minimal'

Custom minimal template for:

- qube 'sys-firewall'
- qube 'sys-net'
- qube 'vault': not networked; used for keepassxc (password manager) and [split gpg](https://www.qubes-os.org/doc/split-gpg/)

### TemplateVM 'fedora-medium' (default template)

Custom template with libreoffice, evolution, ...

- qube 'work': firewalled, ssh only to known hosts and to mail server; used for emails/office work, storing non confidential documents, and terminals (with [tmux](https://en.wikipedia.org/wiki/Tmux)).
- qube 'banking': firewalled, https only to know hosts; used only for e-banking
- qube 'private': not networked; for opening and storing private/personal documents
- qube 'sys-usb': firewalled, only LAN allowed (required for storing large android backups to a NFS share).

### TemplateVM 'fedora-heavy'

Larger custom template with a lot more apps, some from non-fedora repos (rpmfusion, ...)

- qube 'untrusted': firewalled, only a few IPs allowed (eg. own cloud/seafile server, ...); mainly used for managing personal pictures and opening multimedia files and content that is more or less trusted. 
- (named) dispVM 'dispBrowser': for casual browsing. Customized firefox profile with privacy extensions and a custom `user.js` file (from [here](https://github.com/arkenfox/user.js))
- dispVMs: used for opening content downloaded from unknown/dodgy sources as well as browsing sites that won't work with the restricted firefox profile of 'dispBrowser' above.

### TemplateVM 'fedora-print'

A custom template with third-party printing drivers

- (named) dispVM 'print': firewalled, access only to remote printer/scanner

### TemplateVM 'debian-11-signal'

A custom template with `signal-desktop` [installed](https://github.com/Qubes-Community/Contents/blob/master/docs/privacy/signal.md) in a minimal debian-11 template.

- dispVM 'signal'


### Other qubes

- a few Windows 10 qubes without network for CAD/3D drawing, programing controllers with a Windows-only toolkit, ... ; 
- a dedicated qube for GIS work
- ...


DOM0 customization
------------------

### Xterm

Open xterm instead of xfce4-terminal: in `/etc/xdg/xfce4/helpers.rc`, set

~~~
TerminalEmulator=xterm
~~~

(Xresources for xterm are in `$HOME/.Xresources`)


### Power management

- install and configure `tlp` in dom0
- add `workqueue.power_efficient` to `GRUB_CMD_LINE` in `/etc/default/grub`


### Productivity tweaks

Define application shortcuts with Qubes Menu -> System Tools -> Keyboard -> Application Shortcuts; for instance:

- ctrl-alt C: open a calculator in qube untrusted ; shortcut: `qvm-run -q -a untrusted galculator`
- ctrl-alt X: open a popup windows to open xterm in a given qube (script [here](https://github.com/taradiddles/qubes-os/blob/master/popup-appmenu-r4), screenshot [there](https://github.com/taradiddles/qubes-os/blob/master/popup-appmenu.screenshot.jpg)). Shortcut: `popup-appmenu xterm`.
- ctrl-alt F: ditto, but with firefox
- ctrl-alt K: open keepassxc in qube vault; shortcut: `qvm-run -q -a vault keepassxc`


Backups
-------

`qvm-backup` is horribly slow and can't be used on a regular basis to backup qubes with large amounts of data. So use tasket's excellent [wyng](https://github.com/tasket/wyng-backup) backup tool.

Setup (fully automated with scripts):

- in a dedicated trusted qube based on fedora-minimal, mount a nfs share which hosts a large (ie. 500GB) file with a LUKS volume and `losetup` that file
- attach the newly created loop device to dom0
- in dom0, attach the newly create loop device to dom0, open the LUKS volume in the trusted qubes and mount its underlying fs
- in dom0, run `wyng`, backup (rsync) home dir + various config files, etc.
- unmount, close luks, detach, shutdown trusted qube


