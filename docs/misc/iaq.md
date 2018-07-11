Infrequently Asked Questions
============================

## Troubleshooting

### How can I disable Xen Meltdown mitigations?

Set `xpti=false` option in Xen command line (xen.gz option in grub, or options= line in xen.cfg for UEFI).

### How can I switch R4.0 stubdomains back to qemu-traditional?

~~~
qvm-features VMNAME linux-stubdom ''
~~~

### How can I upgrade to testing?

dom0: `sudo qubes-dom0-update --enablerepo=qubes-dom0-current-testing --clean` (or --check-only instead for dom0).

fedora: `sudo dnf update --enablerepo=qubes-vm-*-current-testing --refresh`

debian/whonix: `sudo apt-get update -t *-testing && sudo apt-get dist-upgrade -t *-testing`

This way, you don't need to edit any files for debian/whonix to get the testing.
If you also want to increase reliability further, you can make a dependency/cache check with "sudo apt-get check", which is normally very quick.
For that, under debian/whonix do: `sudo apt-get check && sudo apt-get update -t *-testing && sudo apt-get dist-upgrade -t *-testing`.

### How can I upgrade dom0, templates, and standalones?

Make a dom0 script with the following:

~~~
#!/bin/sh

for domain in $(qvm-ls --fields NAME,CLASS | \
    awk '($2 == "TemplateVM" || $2 == "StandaloneVM") {print $1}'); do
    qvm-run --service $domain qubes.InstallUpdatesGUI
done

sudo qubes-dom0-update
~~~

From https://gist.github.com/JimmyAx/818bcf11a14e85531516ef999c8c5765.
See also the scripts listed under [`OS-administration`](https://github.com/Qubes-Community/Contents/tree/master/code).

### VM fail to start after hard power off

I realized that some VMs refuse to start after a hard power-off (hold power button for 10s).
When running `qvm-start test` I get `vm-test-private missing`.
But this thin volume is actually there.
Also the volume `vm-test-private-snap` is still present.

Try this in dom0:
~~~
sudo pvscan --cache --activate ay
sudo systemctl restart qubesd
qvm-start test
~~~

### Slow VM startup

Use tools like 'systemd-analyze blame' as your guide.

Another service that shows up with significant time is wpa_supplicant. 
You can have it start only for network VMs by creating `/lib/systemd/system/wpa_supplicant.service.d/20_netvms` with the following:
~~~
[Unit]
ConditionPathExists=/var/run/qubes/this-is-netvm
~~~

### Xen passthrough compatible video cards

- https://en.wikipedia.org/wiki/List_of_IOMMU-supporting_hardware#AMD
- http://www.overclock.net/t/1307834/xen-vga-passthrough-compatible-graphics-adapters
- https://wiki.xenproject.org/wiki/Xen_VGA_Passthrough_Tested_Adapters#ATI.2FAMD_display_adapters

### Where are VM log files kept?

In the `/var/log/libvirst/libxl/`, `/var/log/qubes/` and `/var/log/xen/console/` directories.

## Development

### What is a good IDE for Qubes?

QtCreator.

### What is the process flow when starting an AppVM under Qubes R4.x?

1. qvm-start sends a request to qubesd, using Admin API
2. qubesd starts required netvm (recursively), if needed
3. qubesd request qmemman to allocate needed memory for new VM (according to VM's 'memory' property)
4. qubesd calls into appropriate storage pool driver to prepare for VM startup (create copy-on-write layers etc)
5. qubesd gathers needed VM properties etc and builds libvirt VM configuration (XML format, can be seen using `virsh dumpxml`)
6. qubesd calls into libvirt to start the VM (but in paused mode)
7. libvirt setup the VM using libxl, this include starting stubdomain if needed
8. qubesd start auxiliary processes, including:
   - qrexec-daemon
   - qubesdb-daemon (and fill its content)
9. libvirt unpause the VM
10. qvm-start-gui process (running separately from qubesd, as part of dom0 user GUI session) starts gui daemon

See "source" link [here](https://dev.qubes-os.org/projects/core-admin/en/latest/qubes-vm/qubesvm.html#qubes.vm.qubesvm.QubesVM.start).

### What is the process flow when opening a link/file in another VM ?

1. in an AppVM ('srcVM') a link - or file - is set to be opened with the graphical "open in VM" or "open in dispVM" extensions (or respectively with the `/usr/bin/qvm-open-in-vm` or `/usr/bin/qvm-open-in-dvm` command line tools)
2. in src VM, the destination VM is hardcoded to '$dispvm' if dispVMs are used (`/usr/bin/qvm-open-in-dvm` is a simple wrapper to `/usr/bin/qvm-open-in-vm`)
3. in srcVM, `/usr/lib/qubes/qrexec-client-vm` is called, which in turn executes the `qubes.OpenURL` [RPC service](https://www.qubes-os.org/doc/qrexec3/#qubes-rpc-services) to send the url to dstVM
4. in dstVM, `/etc/qubes-rpc/qubes.OpenURL` is called upon reception of the `qubes.OpenURL` RPC event above, which validates the url and executes `/usr/bin/qubes-open`
5. in dstVM, `/usr/bin/qubes-open` executes `xdg-open`, which then opens the url/file with the program registered to handle the associated mime type (for additional info see the [freedesktop specifications](https://www.freedesktop.org/wiki/)).

### How can I contribute to developing Qubes Windows Tools for R4.0?

See [this post](https://www.mail-archive.com/qubes-devel@googlegroups.com/msg02808.html) and thread.

### What are some undocumented QWT registry keys?

MaxFPS, UseDirtyBits.

## Tweaks

### How can I set environment variables for a VM?

Either add to `/etc/environment` or create `~/.envsrc` and set a variable there, then create `.xsessionrc` and source `~/.envsrc`.
See [this thread](https://www.mail-archive.com/qubes-users@googlegroups.com/msg20360.html).

### How would I enable sudo authentication in a Template?

There are two ways to do this now:

1. Follow this [Qubes doc](https://www.qubes-os.org/doc/vm-sudo/#replacing-password-less-root-access-with-dom0-user-prompt) to get the yes/no auth prompts for sudo.

2. Remove the 'qubes-core-agent-passwordless-root' package.

This second way means that sudo no longer works for a normal user. 
Instead, any root access in the VM must be done from dom0 with a command like `qvm-run -u root vmname command`.

### How can I provision a VM with a larger/non-standard swap and /tmp?

Fedora's /tmp uses tmpfs ; it's mounted by systemd at boot time.
See `systemctl status tmp.mount` and `/usr/lib/systemd/system/tmp.mount.d/30_qubes.conf` to increase its size.
Alternatively you can increase the size afterwards with `mount -o remount,size=5G /tmp/`.

If you need to have a disk based tmp you'll have to mask the systemd unit (`systemctl mask tmp.mount`) and put a fstab entry for /tmp.

Alternatively you can add swap with a file inside the vm but it's a bit ugly:
~~~
dd if=/dev/zero of=swapfile bs=1M count=1000
mkswap swapfile
swapon swapfile
~~~

### How do I change display resolution on a Linux HVM?

You only get one resolution at a time.
In the HVM's `/etc/X11/xorg.conf`, in Subsection "Display" for Depth 24, make a single mode like this:

~~~
...
    Subsection "Display"
        Viewport 0 0
        Depth 24
        Modes "1200x800"
    EndSubSection
EndSection
~~~

Only some modes will work. check wikipedia. if your host display is
1080p(1920x1080), then an hvm at 1440x900 works well. if its more than that, might
as well do 1080p in the hvm.

### Manually install Whonix 14 templates

~~~
sudo qubes-dom0-update --enablerepo=qubes-dom0-unstable qubes-core-admin-addon-whonix

sudo qubes-dom0-update --enablerepo=qubes-dom0-unstable qubes-template-whonix-gw-14
qvm-create sys-whonix-14 --class AppVM --template whonix-gw-14 --label black
qvm-prefs sys-whonix-14 provides_network True
qvm-tags whonix-gw-14 a whonix-updatevm

sudo qubes-dom0-update --enablerepo=qubes-dom0-unstable qubes-template-whonix-ws-14
qvm-features whonix-ws-14 whonix-ws 1
qvm-create whonix-ws-dvm-14 --class AppVM --template whonix-ws-14 --label green
qvm-features whonix-ws-dvm-14 appmenus-dispvm 1
qvm-prefs whonix-ws-dvm-14 template_for_dispvms true
qvm-prefs whonix-ws-dvm-14 netvm sys-whonix-14
qvm-prefs whonix-ws-dvm-14 default_dispvm whonix-ws-dvm-14
qvm-tags whonix-ws-14 a whonix-updatevm
~~~
To use the new `sys-whonix-14` for your UpdateVM, perform the following steps:
~~~
qubes-prefs updatevm sys-whonix-14
~~~
Then, edit `/etc/qubes-rpc/policy/qubes.UpdatesProxy` and modify the top lines:
~~~
$type:TemplateVM $default allow,target=sys-whonix
$tag:whonix-updatevm $default allow,target=sys-whonix
~~~
to become:
~~~
$type:TemplateVM $default allow,target=sys-whonix-14
$tag:whonix-updatevm $default allow,target=sys-whonix-14
~~~



*Thanks to all mailing list contributors, from where most of these came.*
