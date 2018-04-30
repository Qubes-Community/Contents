Infrequently Asked Questions
============================

### For troubleshooting, how can I disable Xen Meltdown mitigations?

Set `xpti=false` option in Xen command line (xen.gz option in grub, or options= line in xen.cfg for UEFI).

### What is a good IDE for Qubes?

QtCreator

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

### For troubleshooting, how can I switch R4.0 stubdomains back to qemu-traditional?

~~~
qvm-features VMNAME linux-stubdom ''
~~~

### How can I contribute to developing Qubes Windows Tools for R4.0?

See [this post](https://www.mail-archive.com/qubes-devel@googlegroups.com/msg02808.html) and thread.

### Where are VM log files kept?

In the `/var/log/libvirst/libxl/`, `/var/log/qubes/` and `/var/log/xen/console/` directories.

### How can I upgrade everything to testing?

dom0: `sudo qubes-dom0-update --enablerepo=qubes-dom0-current-testing --clean` (or --check-only instead for dom0).

fedora: `sudo dnf update --enablerepo=qubes-vm-*-current-testing --refresh`

debian/whonix: `sudo apt-get update -t *-testing && sudo apt-get dist-upgrade -t *-testing`

This way, you don't need to edit any files for debian/whonix to get the testing.
If you also want to increase reliability further, you can make a dependency/cache check with "sudo apt-get check", which is normally very quick.
For that, under debian/whonix do: `sudo apt-get check && sudo apt-get update -t *-testing && sudo apt-get dist-upgrade -t *-testing`.

### How can I set environment variables for a VM?

Either add to `/etc/environment` or create `~/.envsrc` and set a variable there, then create `.xsessionrc` and source `~/.envsrc`.
See [this thread](https://www.mail-archive.com/qubes-users@googlegroups.com/msg20360.html).

### How would I enable sudo authentication in a Template?

There are two ways to do this now:

1. Follow this [Qubes doc](https://www.qubes-os.org/doc/vm-sudo/#replacing-password-less-root-access-with-dom0-user-prompt) to get the yes/no auth prompts for sudo.

2. Remove the 'qubes-core-agent-passwordless-root' package.

This second way means that sudo no longer works for a normal user. 
Instead, any root access in the VM must be done from dom0 with a command like `qvm-run -u root vmname command`.

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



*Thanks to all mailing list contributors, from where most of these came.*
