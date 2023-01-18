# Create a Gaming HVM

## Hardware

To have an 'HVM' for gaming, you must have

-   A dedicated GPU. By dedicated, it means: it is a secondary GPU, not
    the GPU used to display dom0. In 2023, 'Nvidia' and 'Amd' GPU work.
    Not tested with Intel GPUs.

-   A screen available for the gaming 'HVM'. (It can be a physical
    monitor or just to have multiple cables connected to the screen and
    switching between input source)

-   Dedicated gaming mouse and keyboard.

-   A lot of patience. GPU passthrough is not trivial, and you will need
    to spend time debugging.

## IOMMU Group

You need to check what are the things/devices that are in the same IOMMU
group as the GPU you want to passthrough. You can't see your IOMMU Group
when you are using Xen (the information is hidden from dom0). So, start
a live linux distribution, enable iommu in the grub options (iommu=1
iommu_amd=on), and then displayed the folder structure of
/sys/kernel/iommu_group

``` bash
#!/bin/bash
shopt -s nullglob
for g in /sys/kernel/iommu_groups/*; do
 echo "IOMMU Group ${g##*/}:"
 for d in $g/devices/*; do
  echo -e "\t$(lspci -nns ${d##*/})"
done
done
```

## GRUB modification

You must hide your secondary GPU from dom0. To do that, you have to
modify the GRUB. In a dom0 Terminal, type:

``` bash
qvm-pci
```

Then find the devices id for your secondary GPU. In my case, it is
`dom0:0a_00.0`{.text} and `dom0:0a_00.1`{.text}. Edit /etc/default/grub,
and add the PCI hiding.

``` text
GRUB_CMDLINE_LINUX="... rd.qubes.hide_pci=0a:00.0,0a:00.1 "
```

then regenerate the grub

``` bash
grub2-mkconfig -o /boot/grub2/grub.cfg
```

If you are using UEFI, the file to override with `grub2-mkconfig`{.text}
is `/boot/efi/EFI/qubes/grub.cfg`{.text}.

Note: if after this step when you reboot the computer you get stuck in
the QubesOS startup that means you are trying to use the GPU you just
hide. Check your BIOS options. Also check the cables, BIOS have some GPU
priority based on the type of cable. For example, DisplayPort can be
favoured over HDMI.

Once you have rebooted, in dom0, type `sudo lspci -vvn`{.bash}, you
should see "Kernel driver in use: pciback" for the GPU you just hide.

## Patching stubdom-linux-rootfs.gz

[github.com/QubesOS/qubes-issues/issues/4321](https://github.com/QubesOS/qubes-issues/issues/4321#issuecomment-423011787)

Copy-paste of the comment:

This is caused by the default TOLUD (Top of Low Usable DRAM) of 3.75G
provided by qemu not being large enough to accommodate the larger BARs
that a graphics card typically has. The code to pass a custom
max-ram-below-4g value to the qemu command line does exist in the
libxl_dm.c file of xen, but there is no functionality in libvirt to add
this parameter. It is possible to manually add this parameter to the
qemu commandline by doing the following in a dom0 terminal. (I modified
the code so it works with 4.1 and remove one of the original limitations
by restricting the modification to VM with a name starting with
"gpu\_\")

``` bash
mkdir stubroot
cp /usr/libexec/xen/boot/qemu-stubdom-linux-rootfs stubroot/qemu-stubdom-linux-rootfs.gz
cd stubroot
gunzip qemu-stubdom-linux-rootfs.gz
cpio -i -d -H newc --no-absolute-filenames < qemu-stubdom-linux-rootfs
rm qemu-stubdom-linux-rootfs
nano init
```

Before the line

``` text
# $dm_args and $kernel are separated with \n to allow for spaces in arguments
```

add:

``` bash
# Patch 3.5 GB limit
vm_name=$(xenstore-read "/local/domain/$domid/name")
# Apply the patch only if the qube name start by "gpu_"
if [ $(echo "$vm_name" | grep -iEc '^gpu_' ) -eq 1 ]; then
 dm_args=$(echo "$dm_args" | sed -n '1h;2,$H;${g;s/\(-machine\nxenfv\)/\1,max-ram-below-4g=3.5G/g;p}')
fi
```

Then execute:

``` bash
find . -print0 | cpio --null -ov \
--format=newc | gzip -9 > ../qemu-stubdom-linux-rootfs
sudo mv ../qemu-stubdom-linux-rootfs /usr/libexec/xen/boot/
```

Note that this will apply the change to the HVM with a name starting
with \"gpu\_\". So you need to name your gaming HVM \"gpu_SOMETHING\".

## Preparing the guest

As of 2023, I recommend using a Linux guest instead of a window guest.

### Windows

Install a window VM, you can use this
[qvm-create-windows-qube](https://github.com/elliotkillick/qvm-create-windows-qube)

### Linux

Create a new standalone Qube based on the template of your choice.

You must run the kernel provided by the guest distribution, because we
will use some non-default kernel module for the GPU driver. Just follow
the doc:
[managing-vm-kernel](https://www.qubes-os.org/doc/managing-vm-kernel/#distribution-kernel).

Install the GPU drivers you need.

## Pass the GPU

In qubes settings for the HVM, go to the 'devices' tab, pass the ID
corresponding to your GPU.

You may or may not need to add the option \"permissive\" or
\"no-strict-reset\".

[Some word about the security implication of thoses
parameters.](https://www.qubes-os.org/doc/device-handling-security/#pci-security)

``` bash
qvm-pci attach gpu_gaming_archlinux dom0:0a_00.0 -o permissive=True -o no-strict-reset=True
qvm-pci attach gpu_gaming_archlinux dom0:0a_00.1 -o permissive=True -o no-strict-reset=True
```

## Starting the guest

This is where you will have a lot of issues to debug.

For Linux guests, run 'sudo dmesg' to have all the kernel log indicating
you if there is a issue with your GPU driver. For some hardware, the MSI
calls won't work. You can work around that using for example
`pci=nomsi`{.text} or `NVreg_EnableMSI=0`{.text} or something else.
Check your drivers options. Check if alternative drivers exist (amdgpu,
nvidia, nouveau, nvidia-open, using drivers from the official website,
...). Check multiple kernel version.

Some links that could help you to debug the issues you will have

-   https://forum.qubes-os.org/t/ryzen-7000-serie/

-   https://dri.freedesktop.org/docs/drm/gpu/amdgpu.html

For windows guests you will probably have the same issues but it will be
harder to debug. I recommend using the drivers from Windows Update
instead of the official drivers from the website of the constructor.

Some things that may be useful for debugging:

-   Virsh (start, define, \...)

-   /etc/libvirt/libxl/

-   xl

-   /etc/qubes/templates/libvirt/xen/by-name/

-   /usr/lib/xen/boot/

-   virsh -c xen:/// domxml-to-native xen-xm /etc/libvirt/libxl/\...

Issues with the drivers could be related to
'qubes-vmm-xen-stubdom-linux', 'qubes-vmm-xen', and the Linux kernel you
will be using.

## Linux guest --- Integration with QubesOS

### Xorg

Now Xorg and Pulseaudio. From XKCD:

[![image](x11){width="\\linewidth"}](https://xkcd.com/963/)

Things you need to install:

-   The Xorg input driver to support your mouse and keyboard

-   A pulseaudio gui client

-   Your favorite Windows Manager

In my case, it is:

``` bash
apt install xserver-xorg-input-kbd xserver-xorg-input-libinput xserver-xorg-input-mouse pavucontrol i3
```

Then create a XORG configuration file for your GPU and screen. My file
named 'AOC.conf':

``` xorg.conf
Section "ServerLayout"
Identifier "Gaming"
Screen 0 "AMD AOC" Absolute 0 0
EndSection

Section "Device"
Identifier  "AMD"

# name of the driver to use. Can be "amdgpu", "nvidia", or something else
Driver      "amdgpu"

# The BusID value will change after each qube reboot. 
BusID       "PCI:0:8:0"
EndSection

Section "Monitor"
Identifier "AOC"
VertRefresh 60
# https://arachnoid.com/modelines/ .  IMPORTANT TO GET RIGHT. MUST ADJUST WITH EACH SCREEN. 
Modeline "1920x1080" 172.80 1920 2040 2248 2576 1080 1081 1084 1118
EndSection

Section "Screen"
Identifier "AMD AOC"
Device     "AMD"
Monitor    "AOC"
EndSection
```

We can't know what is the correct BusID before the qube is started. And
it change after each reboot. So let's write a script --- named
\"xorgX1.sh\" --- that update this configuration file with the correct
value, then start a binary on the Xorg X screen n°1.

``` bash
#!/bin/bash

binary=${1:?binary required}

# Find the correct BusID of the AMD GPU, then set it in the Xorg configuration file
pci=$(lspci | grep "VGA" | grep "NVIDIA|AMD/ATI" | cut -d " " -f 1 | cut -d ":" -f 2 | cut -d "." -f 1 | cut -d "0" -f 2)
sed -i "s/PCI:0:[0-9]:0/PCI:0:$pci:0/g" /home/user/AOC.conf

# Pulseaudio setup
sudo killall pulseaudio
sudo sed -i "s/load-module module-vchan-sink.*/load-module module-vchan-sink domid=$(qubesdb-read -w /qubes-audio-domain-xid)/" /etc/pulse/qubes-default.pa
sudo rm /home/user/.pulse/client.conf
start-pulseaudio-with-vchan
sleep 5 && sudo chmod -R 777 /root/ &
sleep 5 && sudo chmod -R 777 /root/* &
sleep 5 && sudo cp /root/.pulse/client.conf /home/user/.pulse/client.conf && sudo chown -R user:user /home/user/.pulse/client.conf  &

setxkbmap fr
sudo setxkbmap fr

# Start the Xorg server for the X screen number 1.
# The X screen n°0 is already used for QubesOS integration
sudo startx "$binary" -- :1 -config /home/user/AOC.conf
```

### Pulseaudio

So you need to configure pulseaudio for Xorg multiseat. The archlinux
documentation explain that very well: [Xorg
multiseat](https://wiki.archlinux.org/index.php/Xorg_multiseat#Multiple_users_on_single_sound_card:_PulseAudio)
Use the option without system-mode deamon and adapt it to qube: Add the
following line to /etc/pulse/qubes-default.pa

``` bash
load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
```

Then add this config for root:

``` bash
mkdir /root/.pulse
echo "default-server = 127.0.0.1" > /root/.pulse/client.conf
```

The sound was buggy/laggy on my computer. So tried to find a workaround
by playing with pulseaudio settings. It was more or less random tries,
so I can't really explain it: In `/etc/pulse/daemon.conf`{.text} add the
following lines:

``` bash
default-fragments = 60
default-fragment-size-msec = 1
high-priority = no
realtime-scheduling = no
nice-level = 18
```

In `/etc/pulse/qubes-default.pa`{.text} change

``` bash
load-module module-udev-detect
```

to

``` bash
load-module module-udev-detect tsched=0
```

You can launch you favorite Windows Manager like that

``` bash
sudo ./xorgX1.sh /usr/bin/i3
```

### References

-   [Archlinux:
    PulseAudio](https://wiki.archlinux.org/index.php/PulseAudio)

-   [Archlinux:
    PulseAudio/Troubleshooting](https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting)

