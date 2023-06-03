
# Nvidia proprietary driver installation

You can use rpm packages from rpmfusion, or you can build the driver yourself.

## Word of Caution 

Proprietary (NVIDIA/AMD) drivers are known to be sometimes highly problematic, or completely unsupported. 
Radeon driver support is prebaked in the Qubes kernel (v4.4.14-11) but only versions 4000-9000 give or take.
Support for newer cards is limited until AMDGPU support in the 4.5+ kernel, which isn't released yet for Qubes. 

Built in Intel graphics, Radeon graphics (between that 4000-9000 range), and perhaps some prebaked NVIDIA card support that I don't know about. Those are your best bet for great Qubes support.

If you do happen to get proprietary drivers working on your Qubes system (via installing them), please take the time to go to the 
[Hardware Compatibility List (HCL)](https://www.qubes-os.org/doc/hcl/#generating-and-submitting-new-reports )
Add your computer, graphics card, and installation steps you did to get everything working.

Before continuing, you may wish to try the `kernel-latest` package from the `current` repository. This kernel may better support your card and if so, you would not have to rely on proprietary drivers. This can be installed from dom0 with:
~~~
sudo qubes-dom0-update kernel-latest
~~~

## RpmFusion packages

There are rpm packages with all necessary software on rpmfusion. The only package you have to compile is the kernel module (but there is a ready built src.rpm package).

### Download packages

You will need any Fedora 18 system to download and build packages. You can use Qubes AppVM for it, but it isn't necessary. To download packages from rpmfusion - add this repository to your yum configuration (instructions are on their website). Then download packages using yumdownloader:

~~~
yumdownloader --resolve xorg-x11-drv-nvidia
yumdownloader --source nvidia-kmod
~~~

### Build kernel package

You will need at least kernel-devel (matching your Qubes dom0 kernel), rpmbuild tool and kmodtool, and then you can use it to build the package:

~~~
yum install kernel-devel rpm-build kmodtool
rpmbuild --nodeps -D "kernels `uname -r`" --rebuild nvidia-kmod-260.19.36-1.fc13.3.src.rpm
~~~

In the above command, replace `uname -r` with kernel version from your Qubes dom0. If everything went right, you have now complete packages with nvidia drivers for the Qubes system. Transfer them to dom0 (e.g. using a USB stick) and install (using standard "yum install /path/to/file").

Then you need to disable nouveau (normally it is done by install scripts from nvidia package, but unfortunately it isn't compatible with Qubes...):

Edit /etc/default/grub:

~~~
GRUB_CMDLINE_LINUX="quiet rhgb nouveau.modeset=0 rd.driver.blacklist=nouveau video=vesa:off"
~~~

Regenerate grub configuration:

~~~
grub2-mkconfig -o /boot/grub2/grub.cfg
~~~

Reboot.



## Manual installation

This process is quite complicated: First - download the source from nvidia.com site. Here "NVIDIA-Linux-x86\_64-525.116.04" is used. Copy it to dom0. Every next step is done in dom0.

See [this page](https://www.qubes-os.org/doc/copy-to-dom0/) for instructions on how to transfer files to Dom0 (where there is normally no networking).

**WARNING**: Nvidia doesn't sign their files. To make it worse, you are forced to download them over a plaintext connection. This means there are virtually dozens of possibilities for somebody to modify this file and provide you with a malicious/backdoored file. You should realize that installing untrusted files into your Dom0 is a bad idea. Perhaps it might be a better idea to just get a new laptop with integrated Intel GPU? You have been warned.

### Userspace components

Install libraries, Xorg driver, configuration utilities. This can by done by nvidia-installer:

~~~
./NVIDIA-Linux-x86_64-525.116.04.run --ui=none --no-x-check --keep --extract
~~~

### Kernel module

You will need:

-   nvidia kernel module sources (left from previous step)
-   kernel-devel package installed
-   gcc, make, etc

This installation must be done manually, because nvidia-installer refuses to install it on Xen kernel.

To build the kernel module, enter *NVIDIA-Linux-x86\_64-525.116.04/kernel* directory and execute:

~~~
make IGNORE_XEN_PRESENCE=1 CC="gcc -DNV_VMAP_4_PRESENT -DNV_SIGNAL_STRUCT_RLIM"
mv nvidia.ko /lib/modules/$(uname -r)/kernel/drivers/video/
depmod -a
~~~

### Disable nouveau

Add `rd.driver.blacklist=nouveau` option in `/etc/default/grub` (at the end of line `GRUB_CMDLINE_LINUX`).

Install the new grub config with `grub2-mkconfig -o /boot/efi/EFI/qubes/grub.cfg`.

### Reboot

Reboot to verify all this works. You can ensure the module is loaded by running `lsmod | grep nvidia` which should display a single output line, and `lsmod | grep nouveau` should have no output.

## Troubleshooting lack of video output during installation

The GRUB menu may show up fine, the installation environment starts loading, and then the display(s) go into standby mode. This is, typically, related to some sort of an issue with the kernel's KMS/video card modules. See the [Nvidia Troubleshooting](https://www.qubes-os.org/doc/nvidia-troubleshooting/#lack-of-video-output-during-nvidia-driver-installation) guide for troubleshooting steps. 

