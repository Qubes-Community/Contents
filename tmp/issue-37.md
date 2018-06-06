Shrinking volumes on Qubes 4.0
==============================

The [official documentation](https://www.qubes-os.org/doc/resize-disk-image/#shrinking-a-disk-image) describes a safe(ish) way of "shrinking" a VM's volume. This is the recommended approach of shrinking an AppVM's private volume, but it has two caveats:
- it requires copying data, which can take a while
- it is limited to the private volume of VMs based on TemplateVMs

This document describes how to shrink *any* volume.

**The instructions given below are error-prone. ALWAYS BACKUP your data before attempting to shrink a volume.**. `qvm-clone` or `qvm-backup` are your friends. Do not rely only on snapshots (yet).

Note: Qubes 4.0 uses *thin* LVM storage: only the data present on a volume uses disk space, free space isn't allocated physically. If your only concern is disk space, you may simply be careful with how much data you store in a given volume and avoid having to shrink a volume (use `sudo lvs` in dom0 and compare the `LSize` vs `Data%` fields to find out about real disk usage).

The procedure for shrinking a volume on Ext4 and most other filesystems is a bit convoluted because they don't support online shrinking, and we don't want to process any untrusted data in dom0.

The instructions show how to resize a VM's private volume. Simply swap the `-private` volume suffix with `-root` to resize a VM's root volume.

1. backup your data (`qvm-clone` , `qvm-backup`, ...)
2. stop the VM whose volume need to be resized (let's name this VM 'largeVM')
3. start another VM (eg. 'tempVM') with largeVM's private volume attached. 

    ~~~
    qvm-start --hddisk dom0:/dev/qubes_dom0/vm-largeVM-private tempVM`
    ~~~

    (alternatively, you could setup a loop device to point to largeVM's
    private volume and attach it to a running VM).

4. in tempVM, resize the attached volume to 2G (for instance):

    ~~~
    sudo e2fsck -f /dev/xvdi
    sudo resize2fs /dev/xvdi 2G
    ~~~

5. shutdown tempVM

6. in dom0, resize the lvm volume to the **same** size you used at step 4.:

    ~~~
    sudo lvresize -L2G /dev/qubes_dom0/vm-largeVM-private
    ~~~

The procedure is the same for other OSes (eg. MS Windows) but you'll have to use OS specific tools to resize the volume at step 4. and be careful to specify the right shrinked size at step 6.


