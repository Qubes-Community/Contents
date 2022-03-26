Installing a Windows VM
=======================

Simple Windows install
----------------------

If you just want something simple and you can live without some features. This works for Windows XP, 7, 10 and 11, and it may work for Windows 8 and 8.1, although this has not been tested.

**Works:**
- display (1440x900 or 1280x1024 are a nice fit onto FHD hw display)
- keyboard (incl. correct mapping), pointing device
- network (emulated Realtek NIC)

**Does not work:**
- copy & paste (the qubes way)
- copying files into / out of the VM (the qubes way)
- assigning USB devices (the qubes way via the tray applet)
- audio output and input
- PCI device 5853:0001 (Xen platform device) - no driver
- all other features/hardware needing special tool/driver support

**Installation procedure:**
- Have the Windows ISO image (preferrably the 64-bit version) downloaded in some qube.
- Create a new Qube:
  - Name: WindowsQube, Color: orange
  - Standalone Qube not based on a template
  - Networking: sys-firewall (default)
  - Launch settings after creation: check
  - Click "OK".
- Settings:
  - Basic:
    - System storage: 50000+ MB
  - Advanced:
    - Include in memory balancing: uncheck
    - Initial memory: 4096+ MB
    - Kernel: None
    - Mode: HVM
  - Click "Apply".
  - Click "Boot from CDROM":
    - "from file in qube":
      - Select the qube that has the ISO.
      - Select ISO by clicking "...".
    - Click "OK" to boot into the windows installer.
- Windows Installer:
  - Mostly as usual, but automatic reboots will halt the qube - just restart it again and again until the installation is finished.
  - Install on first disk.
  - The Windows license may be read from flash via root in dom0:

    `strings < /sys/firmware/acpi/tables/MSDM`

    Alternatively, you can also try a Windows 7 license key (as of 2018/11
    they are still accepted for a free upgrade to Windows 10).
    
- Afterwards:
  - In case you switch from `sys-network` to `sys-whonix`, you'll need a static IP network configuration, DHCP won't work for `sys-whonix`.
  - Use `powercfg -H off` and `disk cleanup` to save some disk space.


Qubes R4.1 - importing a Windows VM from an earlier version of Qubes
--------------------------------------------------------------------

- Importing from R3.2 or earlier will not work, because  Qubes R3.2 has the old stubdomain by default and this is preserved over backup and restore (as Windows otherwise won't boot.

- Importing from R4.0 should work, see [Migrate backups of Windows VMs created under Qubes R4.0 to R4.1](https://www.qubes-os.org/doc/windows-migrate41/).


Windows VM installation
-----------------------

### qvm-create-windows-qube ###

An unofficial, third-party tool for automating this process is available [here](https://github.com/elliotkillick/qvm-create-windows-qube).
(Please note that this tool has not been reviewed by the Qubes OS Project.
Use it at your own risk.)
However, if you are an expert or want to do it manually you may continue below.

### Summary ###

~~~
qvm-create --class StandaloneVM --label orange --property virt_mode=hvm win7new
qvm-prefs WindowsNew memory 4096
qvm-prefs WindowsNew maxmem 4096
qvm-prefs WindowsNew kernel ''
qvm-volume extend WindowsNew:root 50g
qvm-start --cdrom=untrusted:/home/user/windows_install.iso WindowsNew
# restart after the first part of the windows installation process ends
qvm-start WindowsNew
# once Windows is installed and working
qvm-prefs WindowsNew qrexec_timeout 300
~~~

To install Qubes Windows Tools, follow instructions in [Qubes Windows Tools](https://www.qubes-os.org/doc/windows-tools41/).

### Detailed instructions ###

> **Notes:**
> - The instructions may work on other versions than Windows 7, 10 and 11 x64 but haven't been tested.
>- Qubes Windows Tools (QWT) only supports Windows 7, 10 and 11 x64. For installation, see [Qubes Windows Tools](https://www.qubes-os.org/doc/windows-tools41/).

Create a VM named WindowsNew in [HVM](https://www.qubes-os.org/doc/hvm/) mode (Xen's current PVH limitations precludes from using PVH):

~~~
qvm-create --class StandaloneVM --label red --property virt_mode=hvm WindowsNew
~~~

Windows' installer requires a significant amount of memory or else the VM will crash with such errors:

`/var/log/xen/console/hypervisor.log`:

~~~
p2m_pod_demand_populate: Dom120 out of PoD memory! (tot=102411 ents=921600 dom120)
(XEN) domain_crash called from p2m-pod.c:1218
(XEN) Domain 120 (vcpu#0) crashed on cpu#3:
~~~

So, increase the VM's memory to 4096MB (memory = maxmem because we don't use memory balancing).

~~~
qvm-prefs WindowsNew memory 4096
qvm-prefs WindowsNew maxmem 4096
~~~

Disable direct boot so that the VM will go through the standard cdrom/HDD boot sequence:

~~~
qvm-prefs WindowsNew kernel ''
~~~

A typical Windows 7 installation requires between 25GB up to 60GB of disk space depending on the version (Home/Professional/...). Windows updates also end up using significant space. So, extend the root volume from the default 10GB to at least 50GB (note: it is straightforward to increase the root volume size after Windows is installed: simply extend the volume again in dom0 and then extend the system partition with Windows's disk manager).

~~~
qvm-volume extend WindowsNew:root 25g
~~~

The VM is now ready to be started; the best practice is to use an installation ISO [located in a VM](https://www.qubes-os.org/doc/standalone-and-hvm/#installing-an-os-in-an-hvm):

~~~
qvm-start --cdrom=untrusted:/home/user/windows_install.iso WindowsNew
~~~

Given the higher than usual memory requirements of Windows, you may get a `Not enough memory to start domain 'WindowsNew'` error. In that case try to shutdown unneeded VMs to free memory before starting the Windows VM.

At this point you may open a tab in dom0 for debugging, in case something goes amiss:

~~~
tailf /var/log/qubes/vm-WindowsNew.log \
   /var/log/xen/console/hypervisor.log \
   /var/log/xen/console/guest-WindowsNew-dm.log
~~~

The VM will shutdown after the installer completes the extraction of Windows installation files. It's a good idea to clone the VM now (eg. `qvm-clone WindowsNew WindowsNewbkp1`). Then, (re)start the VM with `qvm-start WindowsNew`.

The second part of Windows' installer should then be able to complete successfully.

Finally, increase the VM's `qrexec_timeout`: in case you happen to get a BSOD or a similar crash in the VM, utilities like `chkdsk` won't complete on restart before `qrexec_timeout` automatically halts the VM. That can really put the VM in a totally unrecoverable state, whereas with higher `qrexec_timeout`, `chkdsk` or the appropriate utility has plenty of time to fix the VM. Note that Qubes Windows Tools also require a larger timeout to move the user profiles to the private volume the first time the VM reboots after the tools' installation.

~~~
qvm-prefs WindowsNew qrexec_timeout 300
~~~

At that point you should have a functional and stable Windows VM, although without updates, Xen's PV drivers nor Qubes integration (see sections [Windows Update](#windows-update) and [Xen PV drivers and Qubes Windows Tools](https://www.qubes-os.org/doc/windows-tools41/#xen-pv-drivers-and-qubes-windows-tools)). It is a good time to clone the VM again.


Windows as TemplateVM
---------------------

Windows 7, 10 and 11 can be installed as TemplateVM by selecting
~~~
qvm-create --class TemplateVM --property virt_mode=HVM --property kernel='' --label black Windows-template
~~~
when creating the VM. To have the user data stored in AppVMs depending on this template, the option `Move User Profiles` has to be selected on installation of Qubes Windows Tools. For Windows 7, before installing QWT, the private disk `D:` has to be renamed to `Q:`, see the QWT installation documentation in [Qubes Windows Tools](https://www.qubes-os.org/doc/windows-tools41/).

AppVMs based on these templates can be created the normal way by using the Qube Manager or by specifying
~~~
qvm-create --class=AppVM --template=<VMname> 
~~~

On starting the AppVM, sometimes a message is displayed that the Xen PV Network Class needs to restart the system. This message can be safely ignored and closed by selecting "No".

**Caution:** These AppVMs must not be started while the corresponding TemplateVM is running, because they share the TemplateVM's license data. Even if this could work sometimes, it would be a violation of the license terms.

Windows 10/11 Usage According to GDPR
-------------------------------------

If Windows 10 or 11 is used in the EU to process personal data, according to GDPR no automatic data transfer to countries outside the EU is allowed without explicit consent of the person(s) concerned, or other legal consent, as applicable. Since no reliable way is found to completely control the sending of telemetry from Windows 10 or 11, the system containing personal data must be completely shielded from the internet.

This can be achieved by installing Windows 10 or 11 in a TemplateVM with the user data directory moved to a separate drive (usually `Q:`). Personal data must not be stored within the TemplateVM, but only in AppVMs depending on this TemplateVM. Network access by these AppVMs must be restricted to the local network and perhaps additional selected servers within the EU. Any data exchange of the AppVMs must be restricted to file and clipboard operations to and from other VMs in the same Qubes system.

Windows update
--------------

Depending on how old your installation media is, fully updating your Windows VM may take *hours* (this isn't specific to Xen/Qubes) so make sure you clone your VM between the mandatory reboots in case something goes wrong. This [comment](https://github.com/QubesOS/qubes-issues/issues/3585#issuecomment-366471111) provides useful links on updating a Windows 7 SP1 VM. For Windows 7, you may find the necessary updates bundled at [WinFuture Windows 7 SP1 Update Pack 2.107 (Vollversion)](https://10gbit.winfuture.de/9Y6Lemoxl-I1_901xOu6Hg/1648348889/2671/Update%20Packs/2020_01/WinFuture_7SP1_x64_UpdatePack_2.107_Januar_2020-Vollversion.exe).

Note: if you already have Qubes Windows Tools installed the video adapter in Windows will be "Qubes video driver" and you won't be able to see the Windows Update process when the VM is being powered off because Qubes services would have been stopped by then. Depending on the size of the Windows update packs it may take a bit of time until the VM shutdowns by itself, leaving one wondering if the VM has crashed or still finalizing the updates (in dom0 a changing CPU usage - eg. shown with `xentop` - usually indicates that the VM hasn't crashed).

To avoid guessing the VM's state enable debugging (`qvm-prefs -s win7new debug true`) and in Windows' device manager (My computer -> Manage / Device manager / Display adapters) temporarily re-enable the standard VGA adapter and disable "Qubes video driver". You can disable debugging and revert to Qubes' display once the VM is updated.

Further customization
---------------------

Please see the [Customizing Windows 7 templates](https://www.qubes-os.org/doc/windows-template-customization/) page (despite the focus on preparing the VM for use as a template, most of the instructions are independent from how the VM will be used - ie. TemplateVM or StandaloneVM).


