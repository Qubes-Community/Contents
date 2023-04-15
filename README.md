# Qubes OS Community Project

**For more information about this project, please see [this
page](https://qubes-community.github.io/).**

This repository hosts user-contributed documentation and code/resources. 

Pending submissions, reviews and QA can be seen in this repository's
[issues](https://github.com/Qubes-Community/Contents/issues) and [pull
requests](https://github.com/Qubes-Community/Contents/pulls).

## User-contributed documentation and links (![](/_res/l.png) icon) to third party docs

[Infrequently Asked Questions](/docs/misc/iaq.adoc)

`common-tasks`
- [how to copy files (and sparse files) from a VM to dom0](/docs/common-tasks/copying-files-to-dom0.md)
- [how to open URLs in another VM](/docs/common-tasks/opening-urls-in-vms.md)

`configuration`
- ![](/_res/l.png) [use Qubes 3.2 OS as a network server](https://github.com/Rudd-O/qubes-network-server)
- ![](/_res/l.png) [use Qubes OS as a smartTV](https://github.com/Aekez/QubesTV)
- ![](/_res/l.png) [VM hardening (fend off malware at VM startup)](https://github.com/tasket/Qubes-VM-hardening)
- ![](/_res/l.png) [VPN configuration](https://github.com/tasket/Qubes-vpn-support)
- [Run wireguard on server and use as VPN for Qubes](/docs/wireguard/README.md)
- [Exposing Mumble server running in Qubes using Wireguard](/docs/mumble/README.md)
- [Make an HTTP Filtering Proxy](/docs/configuration/http-proxy.md)
- ![](/_res/l.png) [Ansible Qubes](https://github.com/Rudd-O/ansible-qubes) (see
  Rudd-O's [other repos](https://github.com/Rudd-O?tab=repositories) as well)
- [shrink VM volumes](/docs/configuration/shrink-volumes.md)
- ![](/_res/l.png) [script to create Windows qubes automatically](https://github.com/elliotkillick/qvm-create-windows-qube)
- [Manage Qubes via dmenu](/docs/configuration/qmenu.md)
- ![](/_res/l.png) [Pihole qube (old post, but also work on QubesOS 4.0)](https://blog.tufarolo.eu/how-to-configure-pihole-in-qubesos-proxyvm/)
- ![](/_res/l.png) [Newer Pihole qube, with cloudflared or NextDNS servers](https://github.com/92VV3M42d3v8/PiHole/blob/master/PiHole%20Cloudflared)
- ![](/_res/l.png) [qubes-dns](https://github.com/3hhh/qubes-dns/)
- [Using multiple languages in dom0](/docs/localization/multi-language-support-dom0.md)
- [How to manage Bluetooth graphically](/docs/configuration/bluetooth.md)
- [How to persist Tailscale tunnel in AppVM](/docs/customization/tailscale.md)
- ![](/_res/l.png) [Verify boot process without Heads or AEM on TPM 2.0](https://github.com/kennethrrosen/qubes-boot-verification)

`coreboot`
- [install coreboot on a Thinkpad x230](/docs/coreboot/x230.md)

`customization`
- [change DPI scaling in dom0 and VMs](/docs/customization/dpi-scaling.md)
- [setup mirage firewall](/docs/customization/mirage-firewall.md)
- [gaming HVM with GPU passthrough](/docs/customization/gaming-hvm.md)
- [Choose deafult terminal settings for a TemplateVM](/docs/customization/terminal-defaults.md)  
- [AwesomeWM](/docs/customization/awesomewm.md)  
- [Screenlockers](/docs/customization/screenlockers.md)  
- ![](/_res/l.png) [QubesOS Autostart Menu](https://github.com/kennethrrosen/Qubes-OS-Autostart-Menu/)
- ![](/_res/l.png) [sys-VPN notification setup](https://github.com/kennethrrosen/qubes_VPN_notifier)
- ![](/_res/l.png) [PAM Distress login script](https://github.com/kennethrrosen/qubes-PAM-distress-login)

`hardware`
- [tips on choosing the right hardware](/docs/hardware/hardware-selection.md)

`localization`
- [how to use multiple keyboard layouts](/docs/localization/keyboard-multiple-layouts.md)

`misc`
- ![](/_res/l.png) [Qubes 3.2 cheat sheet](https://github.com/Jeeppler/qubes-cheatsheet)
- [infrequently asked questions](/docs/misc/iaq.adoc)

`security`
- [multifactor authentication](/docs/security/multifactor-authentication.md)
- [security guidelines](/docs/security/security-guidelines.md)
- [split bitcoin](/docs/security/split-bitcoin.md)
- [split gpg](/docs/security/split-gpg.md)
- [forensics](/docs/security/forensics.md)

`system`
- [understanding and fixing issues with time/clock](/docs/system/clock-time.md)
- [restoring 3.2 templates/standalones to 4.0](/docs/system/restore-3.2.md)
- [connect to a VM console](/docs/system/vm-console.md)
- [display reminders to make regular backups](/docs/system/backup-reminders.md)
- [mount a VM's private storage volume in another VM](/docs/system/vm-image.md)

`user-setups`
- [examples of user setups](/docs/user-setups/) (templates and VMs used, productivity
  tips, customizations, ...)


## User-contributed code and links (![](/_res/l.png) icon) to third party resources

**Prolific authors**
- [Tasket](https://github.com/tasket)

**`OS-administration`**
- ![](/_res/l.png) [qubes4-multi-update](https://github.com/tasket/Qubes-scripts/blob/master/qubes4-multi-update): updates multiple template, standalone VMs and dom0 in R4.0 ([readme](https://github.com/tasket/Qubes-scripts#qubes4-multi-update))
- [R4-universal-update-script.sh](/code/OS-administration/R4-universal-update-script.sh): bash script to automate VM updates
- ![](/_res/l.png) [findpref](https://github.com/tasket/Qubes-scripts/blob/master/findpref): find all VMs that match a pref value and optionally set new values for them ([readme](https://github.com/tasket/Qubes-scripts#findpref))
- ![](/_res/l.png) [qvm-portfwd-iptables](https://gist.github.com/fepitre/941d7161ae1150d90e15f778027e3248): port forwarding to allow external connections, see usage notes at bottom 
- [mount_lvm_image.sh](/code/OS-administration/mount_lvm_image.sh): mount lvm image to a newly created DisposableVM
- [build-archlinux.sh](/code/OS-administration/build-archlinux.sh): build the archlinux template
 
**`monitoring`**
- [ls-qubes.sh](/code/monitoring/ls-qubes.sh): outputs the nb. of running qubes + total memory used; the output can be fed into a panel text applet (see comments in the script).
- ![](/_res/l.png) [qubes-performance](https://github.com/3hhh/qubes-performance)
- ![](/_res/l.png) [qrexec-proxy](https://github.com/3hhh/qubes-qrexec-proxy)
- ![](/_res/l.png) [qubes-callbackd](https://github.com/3hhh/qubes-callbackd)

**`multimedia`**
- sound-control-scripts: toggle, volume up, volume down, ...

**`productivity`**
- toggle-fullscreen-scripts
- screenshot-scripts
- bash autocompletion script for `qvm-*` commands in dom0
- ![](/_res/l.png) [qvm-screenshot-tool](https://github.com/evadogstar/qvm-screenshot-tool)
- ![](/_res/l.png) [qubes-split-dm-crypt](https://github.com/rustybird/qubes-split-dm-crypt)
- ![](/_res/l.png) [qcrypt](https://github.com/3hhh/qcrypt)
- ![](/_res/l.png) [qidle](https://github.com/3hhh/qidle)
- ![](/_res/l.png) [qubes-url-redirector ("Open in Qube")](https://github.com/raffaeleflorio/qubes-url-redirector/)
- ![](/_res/l.png) [qubes-terminal-hotkeys](https://github.com/3hhh/qubes-terminal-hotkeys)
- ![](/_res/l.png) [qubes-conky](https://github.com/3hhh/qubes-conky)
- ![](/_res/l.png) [qvm-ls-mermaid](https://github.com/3hhh/qvm-ls-mermaid)

**`misc`**
- ![](/_res/l.png)
  [halt-vm-by-window](https://github.com/tasket/Qubes-scripts/blob/master/halt-vm-by-window):
  shutdown a Qubes VM associated with the currently active window
  ([readme](https://github.com/tasket/Qubes-scripts#halt-vm-by-window))
- ![](/_res/l.png) [network traffic
  analysis](http://zrubi.hu/en/2017/traffic-analysis-qubes/) (also see Zrubi's
  [other Qubes blog posts](http://zrubi.hu/en/category/virtualization/qubes/) !)
- ![](/_res/l.png) [Ubuntu VMs](http://qubes.3isec.org/): repository with
  templates and packages to set up Ubuntu VMs
- ![](/_res/l.png) [Qubes for Journalists and free-speech defenders](https://github.com/kennethrrosen/journoSEC): a work-in-progress respository of scripts and advice for journalists and human rights workers.
