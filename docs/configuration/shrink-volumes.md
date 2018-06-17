Shrinking volumes
=================

The procedure for shrinking a volume on Ext4 and most other filesystems is bit convoluted because online shrinking isn't supported and we don't want to process any untrusted data in dom0 for security reasons.

**Shrinking volumes is dangerous** and this is why it isn't available in standard Qubes tools. If you have enough disk space, the recommended approach is to create a new VM with a smaller disk and move the data. However, this approach has two caveats:

- it requires copying data, which can take a while
- it is limited to the private volume of VMs based on TemplateVMs

**ALWAYS BACKUP your data before attempting to shrink a volume.**.


Qubes 4.0 (root and private volumes)
------------------------------------

Qubes 4.0 uses *thin* LVM storage: only the data present on a volume uses disk space, free space isn't allocated physically. If your only concern is disk space, you may simply be careful with how much data you store in a given volume and avoid having to shrink a volume (use `sudo lvs` in dom0 and compare the `LSize` vs `Data%` fields to find out about real disk usage).

The instructions below show how to resize a Linux VM's private volume. For root volumes, swap the `-private` volume suffix with `-root`. For other OSes (eg. MS Windows) you'll have to use the OS' specific tools to resize the volume at step 4 instead of `resize2fs`, and to be careful to specify the right shrinked size at step 6.

1. backup your data with `qvm-clone` , `qvm-backup`, or your own backup mechanism. Do not rely only on snapshots (yet)
2. stop the VM (eg. 'largeVM') whose volume has to be resized
3. start another VM (eg. 'tempVM') with largeVM's private volume attached:

    ~~~
    qvm-start --hddisk dom0:/dev/qubes_dom0/vm-largeVM-private tempVM
    ~~~

    Alternatively, you could setup a loop device in dom0 associated to largeVM's private volume and attach it to a running VM but this is outside the scope of this document (see `losetup` and `qvm-block`).

4. in tempVM, resize the attached volume:

    ~~~
    sudo e2fsck -f /dev/xvdi
    sudo resize2fs /dev/xvdi <newsize>
    ~~~

    (eg. `<newsize>` = `2G` ; see `man resize2fs` for allowed formats).

5. shutdown tempVM

6. in dom0, resize the lvm volume to the **SAME** size you used at step 4. (specifying a lower size than the underlying filesystem's size **will corrupt** the filesystem and either destroy some of your data or trigger filesystem exceptions when the filesystem tries to write at a location that doesn't exist):

    ~~~
    sudo lvresize -L<newsize> /dev/qubes_dom0/vm-largeVM-private
    ~~~



Qubes 3.2 (Linux VMs, private image only)
-----------------------------------------

First you need to start VM without `/rw` mounted. One possibility is to interrupt its normal startup by adding the `rd.break` kernel option:

~~~
qvm-prefs -s <vm-name> kernelopts rd.break
qvm-start --no-guid <vm-name>
~~~

And wait for qrexec connect timeout (or simply press Ctrl-C). Then you can connect to VM console and shrink the filesystem:

~~~
sudo xl console <vm-name>
# you should get dracut emergency shell here
mount --bind /dev /sysroot/dev
chroot /sysroot
mount /proc
e2fsck -f /dev/xvdb
resize2fs /dev/xvdb <new-desired-size>
umount /proc
exit
umount /sysroot/dev
poweroff
~~~

Now you can resize the image:

~~~
truncate -s <new-desired-size> /var/lib/qubes/appvms/<vm-name>/private.img
~~~

It is **critical** to use the same (or bigger for some safety margin) size in truncate call compared to the `resize2fs` call. Otherwise **you will lose your data!**. 

Then reset kernel options back to default:

~~~
qvm-prefs -s <vm-name> kernelopts default
~~~

Done.

In order to avoid errors, you might want to first reduce the filesystem to a smaller size than desired (say 3G), then truncate the image to the target size (for example 4G), and lastly grow the filesystem to the target size. In order to do this, after the `truncate` step, start the vm again in maintenance mode and use the following command to extend the filesystem to the correct size:

~~~
resize2fs /dev/xvdb
~~~

With no argument, `resize2fs` grows the filesystem to match the underlying block device (the .img file you just shrunk).
