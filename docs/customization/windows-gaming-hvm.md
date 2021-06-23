# Create a Gaming HVM

Some information to configure a windows HVM for gaming. 
This is not officially supported, just some community trial & errors.
This doc is also hosted on
https://neowutran.ovh/qubes/articles/gaming_windows_hvm.html

## References

Everythings needed is referenced here

-   [Usefull technical details](https://paste.debian.net/1043341/)

-   [Reddit thread of what is needed for GPU
    passthrough](https://www.reddit.com/r/Qubes/comments/9hp3e7/gpu_passthrough_howto/)

-   [Solution to have more than 3Go of RAM in the Windows
    HVM](https://github.com/QubesOS/qubes-issues/issues/4321#issuecomment-423011787)

-   [Some old
    references](https://www.reddit.com/r/Qubes/comments/66wk4q/gpu_passthrough/)

## Prerequise

You have a functional Windows HVM (Windows 7 or Windows 10). The \"how
to\" for this part can be found on the Qubes OS documentation and here:
[Usefull github
comment](https://github.com/QubesOS/qubes-issues/issues/3585#issuecomment-453200971).
However, few tips:

-   Do a backup (clone VM) of the Windows HVM BEFORE starting to install
    QWT (installing QWT is not required)

## Hardware

To have a Windows HVM for gaming, you must have:

-   A dedicated AMD GPU. By dedicated, it means: it is a secondary GPU,
    not the GPU used to display dom0. Nvidia GPU are not supported (or
    maybe with a lot of tricks).

-   A really fast disk (M.2 disk)

-   A lot of RAM

-   A dedicated screen

-   Dedicated gaming mouse and keyboard

In my case:

-   Secondary GPU: AMD RX580

-   Primary GPU: Some Nvidia trash, used for dom0

-   32Go of RAM. 12Go of RAM will be dedicated for the Windows HVM

-   A fast M.2 disk

## Checklist

Short list of things to do to make the GPU passthrough work:

-   You verified and confirmed that the secondary GPU is alone in its
    IOMMU Group

-   In dom0, you edited the file `/etc/default/grub` or
    `/boot/efi/EFI/qubes/xen.cfg` or
    `/boot/efi/EFI/qubes/grub.cfg` to allow PCI hiding for your
    secondary GPU, and regenerated the grub if needed

-   You have patched stubdom-linux-rootfs.gz to allow to have more than
    3Go of RAM for your HVM

## IOMMU Group

Warning: I am far from understanding the IOMMU group. Check online
references on that subject. It seems that you can only do a successfull
GPU passthough if you can passthrough everything that is in the IOMMU
Group of the GPU. Also, you can't see your IOMMU Group when you are
using Xen (the information is hidden from dom0). So, what I did: I
booted from a Linux Mint Live USB. In the grub I enabled the IOMMU
(iommu=1 iommu_amd=on), and then displayed the folder structure of
/sys/kernel/iommu_group

``` bash
tree /sys/kernel/iommu_group
```

My secondary GPU was alone in its IOMMU group.

## GRUB modification

You must hide your secondary GPU from dom0. To do that, you have to edit
the GRUB. In a dom0 Terminal, type:

``` bash
qvm-pci
```

Then find the devices id for your secondary gpu. In my case, it is
`dom0:0a_00.0` and `dom0:0a_00.1`. Edit /etc/default/grub,
and add the PCI hiding

``` text
GRUB_CMDLINE_LINUX="... rd.qubes.hide_pci=0a:00.0,0a:00.1 "
```

then regenerate the grub

``` bash
grub2-mkconfig -o /boot/grub2/grub.cfg
```

Or if using UEFI boot, edit `/boot/efi/EFI/qubes/xen.cfg` or
`/boot/efi/EFI/qubes/grub.cfg` and add the
`rd.qubes.hide_pci=` option to the `kernel=` line.

## Patching stubdom-linux-rootfs.gz

### Qubes R4.0

Follow the instructions here:\
[github.com/QubesOS/qubes-issues/issues/4321](https://github.com/QubesOS/qubes-issues/issues/4321#issuecomment-423011787)

Copy-paste of the comment:

This is caused by the default TOLUD (Top of Low Usable DRAM) of 3.75G
provided by qemu not being large enough to accommodate the larger BARs
that a graphics card typically has. The code to pass a custom
max-ram-below-4g value to the qemu command line does exist in the
libxl_dm.c file of xen, but there is no functionality in libvirt to add
this parameter. It is possible to manually add this parameter to the
qemu commandline by doing the following in a dom0 terminal:

``` bash
mkdir stubroot
cp /usr/lib/xen/boot/stubdom-linux-rootfs stubroot/stubdom-linux-rootfs.gz
cd stubroot
gunzip stubdom-linux-rootfs.gz
cpio -i -d -H newc --no-absolute-filenames < stubdom-linux-rootfs
rm stubdom-linux-rootfs
nano init
```

Before the line

``` text
#$dm_args and $kernel are separated with \x1b to allow for spaces in arguments.
```

add:

``` bash
SP=$'\x1b'
dm_args=$(echo "$dm_args" \
 | sed "s/-machine\\${SP}xenfv/-machine\
\\${SP}xenfv,max-ram-below-4g=3.5G/g")
```

Then execute:

``` bash
find . -print0 | cpio --null -ov \
--format=newc | gzip -9 > ../stubdom-linux-rootfs
sudo mv ../stubdom-linux-rootfs /usr/lib/xen/boot/
```

Note that this will apply the change to all HVMs, so if you have any
other HVM with more than 3.5G ram assigned, they will not start without
the adapter being passed through. Ideally to fix this libvirt should be
extended to pass the max-ram-below-4g parameter through to xen, and then
a calculation added to determine the correct TOLUD based on the total
BAR size of the PCI devices are being passed through to the vm.

### Qubes R4.1

For Qubes R4.1 follow the R4.0 section, except for two things.

-   The file that need to be patched is now
    \"/usr/libexec/xen/boot/qemu-stubdom-linux-rootfs\"

-   The content of the \"init\" file to modify.

#### The content of the \"init\" file

Before the line

``` text
# $dm_args and $kernel are separated with \n to allow for spaces in arguments
```

add:

``` bash
# Patch 3.5 Go limit
vm_name=$(xenstore-read "/local/domain/$domid/name")
# Apply the patch only if the qube name start by "gpu_"
if [ $(echo "$vm_name" | grep -iEc '^gpu_' ) -eq 1 ]; then
 dm_args=$(echo "$dm_args" | sed -n '1h;2,$H;${g;s/\(-machine\nxenfv\)/\1,max-ram-below-4g=3.5G/g;p}')
fi
```

## Pass the GPU

In qubes settings for the windows HVM, go to the \"devices\" tab, pass
the ID corresponding to your AMD GPU. (in my case, it was 0a:00.0 and
0a:00.1) And check the option for \"nostrict reset\" for those 2. In
some case, you might also need to set the \"permissive\" flag to true
(But I didn't need that with the RX 580):

``` bash
qvm-pci attach windows-hvm dom0:0a_00.0 -o permissive=True -o no-strict-reset=True
qvm-pci attach windows-hvm dom0:0a_00.1 -o permissive=True -o no-strict-reset=True
```

## Conclusion

Don't forget to install the GPU drivers, you can install the official
one from AMD website, no modification or trick to do. Nothing else is
required to make it work (in my case at least, once I finish to fight to
find those informations). If you have issues, you can refer to the links
in the first sections. If it doesn't work and you need to debug more
things, you can go deeper.

-   Virsh (start, define, \...)

-   /etc/libvirt/libxl/

-   xl

-   /etc/qubes/templates/libvirt/xen/by-name/

-   /usr/lib/xen/boot/

-   virsh -c xen:/// domxml-to-native xen-xm /etc/libvirt/libxl/\...

I am able to play games on my windows HVM with very good performances.
And safely.

## Bugs

The AMD GPUs have a bug when used in HVM: each time you will reboot your
windows HVM, it will get slower and slower. It is because the AMD GPUs
is not correctly resetted when you restart your windows HVM Two
solutions for that:

-   Reboot your computer

-   In the windows HVM, use to windows option in the system tray to
    \"safely remove devices\", remove your GPU. Restart the HVM.

This bug is referenced somewhere, but lost the link and too lazy to
search for it.
