Qubes Windows Tools
===================

Qubes Windows Tools are a set of programs and drivers that provide integration of Windows AppVMs with the rest of the Qubes system. Currently the following features are available for Windows VMs after installation of those tools:

-   **Qubes Video Driver** - provides for the Seamless GUI mode that integrates apps windows onto the common Qubes trusted desktop (cuurently only for Windows 7)
-   **File sender/receiver** - Support for [secure clipboard copy/paste](https://www.qubes-os.org/doc/copy-paste/) between the Windows VM and other AppVMs
-   **File sender/receiver** - Support for [secure file exchange](https://www.qubes-os.org/doc/copying-files/) between the Windows VM and other AppVMs
-   **Copy/Edit in Disposable VM** - Support for editing files in DisposableVMs as well as for qvm-run and generic qrexec for the Windows VM (e.g. ability to run custom service within/from the Windows VM)
-   **Xen PV drivers** for Windows that increase performance compared to qemu emulated devices

Below is a breakdown of the feature availability depending on the windows version:

|             Feature                  |  Windows 7 x64 | Windows 10/11 x64 |
| ------------------------------------ | :------------: | :---------------: |
| Qubes Video Driver                   |        +       |         -         |
| Qubes Network Setup                  |        +       |         +         |
| Private Volume Setup (move profiles) |        +       |         +         |
| File sender/receiver                 |        +       |         +         |
| Clipboard Copy/Paste                 |        +       |         +         |
| Application shortcuts                |        +       |         +         |
| Copy/Edit in Disposable VM           |        +       |         +         |
| Block device                         |        +       |         +         |
| USB device                           |        +       |         +         |
| Audio                                |        +       |         +         |

Qubes Windows Tools are open source and are distributed under a GPL license.

NOTES:
- Currently only 64-bit versions of Windows 7, 10 and 11 are supported by Qubes Windows Tools. Only emulated SVGA GPU is supported (although [there has been reports](https://groups.google.com/forum/#!topic/qubes-users/cmPRMOkxkdA) on working GPU passthrough).
- __This page documents the process of installing Qubes Windows Tools in version R4.1.__.

Preparation
-----------

Before proceeding with the installation we need to disable the Windows mechanism that allows only signed drivers to be installed, because currently (beta releases) the drivers we provide as part of the Windows Tools are not digitally signed with a publicly recognizable certificate. To do that:

-   Start the command prompt as Administrator, i.e. right click on the Command Prompt icon (All Programs -> Accessories) and choose "Run as administrator"
-   In the command prompt type `bcdedit /set testsigning on`
-   Reboot your Windows VM

In the future this step will not be necessary anymore, because we will sign our drivers with a publicly verifiable certificate. However, it should be noted that even now, the fact that those drivers are not digitally signed, this doesn't affect security of the Windows VM in 'any' way. This is because the actual installation `iso` file can be verified as described in step 3 below. The only downside of those drivers not being signed is the inconvenience to the user that he or she must disable the signature enforcement policy before installing the tools.

Installing Windows OS in a Qubes VM
-----------------------------------

Please refer to [this page](https://www.qubes-os.org/doc/windows-vm41.md/) for instructions on how to install Windows in a Qubes VM.

NOTE: It is strongly suggested to enable autologon for any Windows HVMs that will have Qubes Tools installed. To do so, run `netplwiz` command from the `Win+R`/Start menu and uncheck the *Users must enter a user name and password to use this computer* option.

Installing Qubes guest tools in Windows VMs
-------------------------------------------

This will allow you to install the Qubes Windows Tools on Windows 7, 10 and 11 both as a StandaloneVM as well as a Template VM and a corresponding AppVM. But some features are not available:

> **Note:** seamless mode is currently not available for windows 10 and 11. Please check the top of this document for the full feature availability breakdown.

 1. Download the [Qubes Windows Tools installation disk](https://github.com/tabit-pro/qubes-windows-tools-cross/releases/download/v4.1.67/qubes-windows-tools-4.1.67.1.iso/) into some AppVM.

 2. Download the [checksumfile](https://github.com/tabit-pro/qubes-windows-tools-cross/releases/download/v4.1.67/sha256sum.txt) into the same AppVM.
 
 3. Check the integrity of the file `qubes-windows-tools-4.1.67.1.iso` by comparing its hash checksum. This can be done using the `sha256sum` command in the AppVM like:
        
		sha256sum qubes-windows-tools-4.1.67.1.iso

	and compare it to the value stored in the file `sha256sum.txt` for the `iso` file (**it has to exactly match for security reasons**). If it matches, feel free to continue the installation. If not, repeat the download to make sure it was not corrupted due to a network problem. If keeps on not matching it might be an attacker attempting to do something nasty to your system -- Ask for support.

    > **Note**: this is a workaround for installing the Qubes windows tools since the tools are not yet available in the Qubes repositories.

 4. Start the Windows qube attaching the `iso` file as a virtual CD-Rom drive *(where `<VMname>` is the name of your Windows VM and <AppVM> the name of the AppVM where you downloaded the installation `iso`)*

                qvm-start <VMname> --cdrom=<AppVM>:/PATH_TO_THE_FILE/qubes-windows-tools-4.1.67.1.iso

       Once the Windows VM boots, a CDROM should appear in the 'My Computer' menu (typically as `D:`) with the setup program `qubes-tools-x64.msi` in its main directory.

 5. Install Qubes Windows Tools 4.1.67.1 by starting `qubes-tools-x64.msi`, optionally selecting the `Xen PV disk drivers`. For Windows 10 and 11, but not Windows 7, you should select `Move user profiles` (which would probably lead to problems in Windows 7). If during installation, the Xen driver requests a reboot, select "No" and let the installation continue - the system will be rebooted later.

 6. After successful installation, the Windows VM must be shut down and started again, possibly a couple of times. On each shutdown, wait until the VM is really stopped, i.e. Qubes shows no more activity.

 7. Qubes will automatically detect the tools has been installed in the VM and will set appropriate properties for the VM, such as `qrexec_installed`, `guiagent_installed`, and `default_user`. This can be verified (but is not required) using the `qvm-prefs` command  *(where `<VMname>` is the name of your Windows VM)*:

	        qvm-prefs <VMname>

	> **Note:** it is recommended to increase the default value of Windows VM's `qrexec_timeout` property from 60 (seconds) to, for example, 300. During one of the first reboots after Windows Tools installation Windows user profiles are moved onto the private VM's virtual disk (private.img) and this operation can take some time. *(Currently this only works for Windows 10 and 11.)* Moving profiles is performed in an early boot phase when `qrexec` is not yet running, so timeout may occur with the default value. To change the property use this command in `dom0`:
  
	        qvm-prefs <VMname> qrexec_timeout 300

 	It is also advisable to set some other parameters in order to enable audio, synchronize the Windows clock with the Qubes clock, and so on:
	        
	        qvm-features <VMname> gui 1
	        qvm-features <VMname> gui-emulated 1
	        qvm-features <VMname> audio-model ich9
	        qvm-features <VMname> stubdom-qrexec 1
	        qvm-features <VMname> timezone localtime
	        qvm-prefs <VMname> qrexec_timeout 300

 8. Reboot Windows. If the VM starts, but does not show any window then shutdown Windows from the Qube manager, wait until it has really stopped, and reboot Windows once more.
 
 9. Now the system should be up, with QWT running correctly.
 
 10. For Windows 7, optionally enable seamless mode. This can be done using the Windows command `regedit` on the windows command prompt (`cmd.exe`) and, in the registry editor, positioning to the keys `\HKLM\Software\Invisible Things Lab\Qubes Tools\` and `\HKLM\Software\Invisible Things Lab\Qubes Tools\qga\` and changing the value for the entries `SeamlessMode` in both keys from 0 to 1. After the next boot, the VM will start in seamless mode.
	
 11. Lastly to enable file copy operations to a Windows VM the `default_user` property should be set the `<username>` that you use to login to the Windows VM. This can be done via the following command on a `dom0` terminal: *(where `<VMname>` is the name of your Windows 10 VM)*
  
		`qvm-prefs <VMname> default_user <username>`

     > **Note:** If this property is not set or set to a wrong value, files copied to this VM are stored in the folder `C:\Windows\System32\config\systemprofile\Documents\QubesIncoming\<source_VM>`.
	 > If the target VM is an AppVM, this has the consequence that the files are stored in the corresponding TemplateVM and so are lost on AppVM shutdown.

Xen PV drivers and Qubes Windows Tools
--------------------------------------

Installing Xen's PV drivers in the VM will lower its resources usage when using network and/or I/O intensive applications, but *may* come at the price of system stability (although Xen's PV drivers on a Windows VM are usually very stable). They can be installed as an optional part of Qubes Windows Tools (QWT), which bundles Xen's PV drivers.

Notes about using Xen's VBD (storage) PV driver:
- **Windows 7:** Installing the driver requires a fully updated VM or else you'll likely get a BSOD and a VM in a difficult to fix state. Updating Windows takes *hours* and for casual usage there isn't much of a performance between the disk PV driver and the default one; so there is likely no need to go through the lengthy Windows Update process if your VM doesn't have access to untrusted networks and if you don't use I/O intensive apps or attach block devices. If you plan to update your newly installed Windows VM it is recommended that you do so *before* installing Qubes Windows Tools (QWT).
- The option to install the storage PV driver is disabled by default in Qubes Windows Tools 
- In case you already had QWT installed without the storage PV driver and you then updated the VM, you may then install the driver by again starting the QWT installer and selecting the change option.

Using Windows AppVMs in seamless mode
-------------------------------------

> **Note:** This feature is only available for Windows 7

Once you start a Windows-based AppVM with Qubes Tools installed, you can easily start individual applications from the VM (note the `-a` switch used here, which will auto-start the VM if it is not running):

~~~
qvm-run -a my-win7-appvm explorer.exe
~~~

![windows-seamless-4.png](/attachment/wiki/WindowsAppVms/windows-seamless-4.png) ![windows-seamless-1.png](/attachment/wiki/WindowsAppVms/windows-seamless-1.png)

Also, the inter-VM services work as usual -- e.g. to request opening a document or URL in the Windows AppVM from another VM:

~~~
[user@work ~]$ qvm-open-in-vm work-win7 roadmap.pptx
~~~

~~~
[user@work ~]$ qvm-open-in-vm work-win7 https://invisiblethingslab.com
~~~

... just like in the case of Linux AppVMs. Of course all those operations are governed by central policy engine running in Dom0 -- if the policy doesn't contain explicit rules for the source and/or target AppVM, the user will be asked whether to allow or deny the operation.

Inter-VM file copy and clipboard works for Windows AppVMs the same way as for Linux AppVM (except that we don't provide a command line wrapper, `qvm-copy-to-vm` in Windows VMs) -- to copy files from Windows AppVMs just right-click on the file in Explorer, and choose: Send To-\> Other AppVM.

To simulate CTRL-ALT-DELETE in the HVM (SAS, Secure Attention Sequence), press Ctrl-Alt-Home while having any window of this VM in the foreground.

![windows-seamless-7.png](/attachment/wiki/WindowsAppVms/windows-seamless-7.png)

Changing between seamless and full desktop mode
-----------------------------------------------

You can switch between seamless and "full desktop" mode for Windows HVMs in their settings in Qubes Manager. The latter is the default.

Using template-based Windows AppVMs
-----------------------------------

Qubes allows HVM VMs to share a common root filesystem from a select Template VM, just as for Linux AppVMs. This mode is not limited to Windows AppVMs, and can be used for any HVM (e.g. FreeBSD running in a HVM). 

In order to create a HVM TemplateVM one can use the following command, suitably adapted:

~~~
qvm-create --class TemplateVM win-template --property virt_mode=HVM --property kernel=''  -l green
~~~

... , set memory as appropriate, and install the Windows OS (or any other OS) into this template the same way as you would install it into a normal HVM -- please see instructions on [this page](https://www.qubes-os.org/doc/hvm-create/).

If you use this Template as it is, then any HVMs that use it will effectively be DisposableVMs - the User directory will be wiped when the HVM is closed down.

If you want to retain the User directory between reboots, then it would make sense to store the `C:\Users` directory on the 2nd disk which is automatically exposed by Qubes to all HVMs. 
This 2nd disk is backed by the `private.img` file in the AppVMs' and is not reset upon AppVMs reboot, so the user's directories and profiles would survive the AppVMs reboot, unlike the "root" filesystem which will be reverted to the "golden image" from the Template VM automatically. 
To facilitate such separation of user profiles, Qubes Windows Tools provide an option to automatically move `C:\Users` directory to the 2nd disk backed by `private.img`. 
It's a selectable feature of the installer, but currently working only for Windows 10 and 11. 
If that feature is selected during installation, completion of the process requires two reboots:

-   The private disk is initialized and formatted on the first reboot after tools installation. It can't be done **during** the installation because Xen mass storage drivers are not yet active.
-   User profiles are moved to the private disk on the next reboot after the private disk is initialized. 
Reboot is required because the "mover utility" runs very early in the boot process so OS can't yet lock any files in there. 
This can take some time depending on the profiles' size and because the GUI agent is not yet active dom0/Qubes Manager may complain that the AppVM failed to boot. 
That's a false alarm (you can increase the AppVM's default boot timeout using `qvm-prefs`), the VM should appear "green" in Qubes Manager shortly after.

For Windows 7, the user directories have to be moved manually, because the automatic transfer during QWT installation does not work for not yet known reasons.

It also makes sense to disable Automatic Updates for all the template-based AppVMs -- of course this should be done in the Template VM, not in individual AppVMs, because the system-wide settings are stored in the root filesystem (which holds the system-wide registry hives). Then, periodically check for updates in the Template VM and the changes will be carried over to any child AppVMs.

Once the template has been created and installed it is easy to create AppVMs based on it:

~~~
qvm-create --property virt_mode=hvm <new windows appvm name> --template <name of template vm> --label <label color>
~~~

Components
----------

Qubes Windows Tools (QWT for short) contain several components than can be enabled or disabled during installation:

- Shared components (required): common libraries used by QWT components.
- Xen PV drivers: drivers for the virtual hardware exposed by Xen.
   - Base Xen PV Drivers (required): paravirtual bus and interface drivers.
   - Xen PV Disk Drivers: paravirtual storage drivers.
   - Xen PV Network Drivers: paravirtual network drivers.
- Qubes Core Agent: qrexec agent and services. Needed for proper integration with Qubes.
   - Move user profiles: user profile directory (c:\users) is moved to VM's private disk backed by private.img file in dom0 (useful mainly for HVM templates).
- Qubes GUI Agent: video driver and gui agent that enable seamless showing of Windows applications on the secure Qubes desktop.
- Disable UAC: User Account Control may interfere with QWT and doesn't really provide any additional benefits in Qubes environment.

**In testing VMs only** it's probably a good idea to install a VNC server before installing QWT. If something goes very wrong with the Qubes gui agent, a VNC server should still allow access to the OS.

**NOTE**: Xen PV disk drivers are not installed by default. This is because they seem to cause problems (BSOD = Blue Screen Of Death). We're working with upstream devs to fix this. *However*, the BSOD seems to only occur after the first boot and everything works fine after that. **Enable the drivers at your own risk** of course, but we welcome reports of success/failure in any case (backup your VM first!). With disk PV drivers absent `qvm-block` will not work for the VM, but you can still use standard Qubes inter-VM file copying mechanisms.

Xen PV driver components may display a message box asking for reboot during installation -- it's safe to ignore them and defer the reboot.

Installation logs
-----------------

If the install process fails or something goes wrong during it, include the installation logs in your bug report. They are created in the `%TEMP%` directory, by default `<user profile>\AppData\Local\Temp`. There are two text files, one small and one big, with names starting with `Qubes_Windows_Tools`.

Uninstalling QWT is supported from version 3.2.1. Uninstalling previous versions is **not recommended**.
After uninstalling you need to manually enable the DHCP Client Windows service, or set IP settings yourself to restore network access.

Configuration
-------------

Starting from version 2.2.\* various aspects of Qubes Windows Tools can be configured through the registry. The main configuration key is located in `HKEY_LOCAL_MACHINE\SOFTWARE\Invisible Things Lab\Qubes Tools`. Configuration values set on this level are global to all QWT components. It's possible to override global values with component-specific keys, this is useful mainly for setting log verbosity for troubleshooting. Possible configuration values are:

|**Name**|**Type**|**Description**|**Default value**|
|:-------|:-------|:--------------|:----------------|
|LogDir|String|Directory where logs are created|c:\\Program Files\\Invisible Things Lab\\Qubes Tools\\log|
|LogLevel|DWORD|Log verbosity (see below)|2 (INFO)|
|LogRetention|DWORD|Maximum age of log files (in seconds), older logs are automatically deleted|604800 (7 days)|

Possible log levels:

||
|1|Error|Serious errors that most likely cause irrecoverable failures|
|2|Warning|Unexpected but non-fatal events|
|3|Info|Useful information (default)|
|4|Debug|Internal state dumps for troubleshooting|
|5|Verbose|Trace most function calls|

Debug and Verbose levels can generate large volume of logs and are intended for development/troubleshooting only.

To override global settings for a specific component, create a new key under the root key mentioned above and name it as the executable name, without `.exe` extension. For example, to change qrexec-agent's log level to Debug, set it like this:

![qtw-log-level.png](/attachment/wiki/WindowsTools/qtw-log-level.png)

Component-specific settings currently available:

|**Component**|**Setting**|**Type**|**Description**|**Default value**|
|:------------|:----------|:-------|:--------------|:----------------|
|qga|DisableCursor|DWORD|Disable cursor in the VM. Useful for integration with Qubes desktop so you don't see two cursors. Can be disabled if you plan to use the VM through a remote desktop connection of some sort. Needs gui agent restart to apply change (locking OS/logoff should be enough since qga is restarted on desktop change).|1|

Troubleshooting
---------------

If the VM is inaccessible (doesn't respond to qrexec commands, gui is not functioning), try to boot it in safe mode:

-   `qvm-start --debug vmname`
-   mash F8 on the boot screen to enable boot options and select Safe Mode (optionally with networking)

Safe Mode should at least give you access to logs (see above).

**Please include appropriate logs when reporting bugs/problems.** Starting from version 2.4.2 logs contain QWT version, but if you're using an earlier version be sure to mention which one. If the OS crashes (BSOD) please include the BSOD code and parameters in your bug report. The BSOD screen should be visible if you run the VM in debug mode (`qvm-start --debug vmname`). If it's not visible or the VM reboots automatically, try to start Windows in safe mode (see above) and 1) disable automatic restart on BSOD (Control Panel - System - Advanced system settings - Advanced - Startup and recovery), 2) check the system event log for BSOD events. If you can, send the `memory.dmp` dump file from c:\Windows.
Xen logs (/var/log/xen/console/guest-*) are also useful as they contain pvdrivers diagnostic output.

If a specific component is malfunctioning, you can increase its log verbosity as explained above to get more troubleshooting information. Below is a list of components:

||
|qrexec-agent|Responsible for most communication with Qubes (dom0 and other domains), secure clipboard, file copying, qrexec services.|
|qrexec-wrapper|Helper executable that's responsible for launching qrexec services, handling their I/O and vchan communication.|
|qrexec-client-vm|Used for communications by the qrexec protocol.|
|qga|Gui agent.|
|QgaWatchdog|Service that monitors session/desktop changes (logon/logoff/locking/UAC...) and simulates SAS sequence (ctrl-alt-del).|
|qubesdb-daemon|Service for accessing Qubes configuration database.|
|network-setup|Service that sets up network parameters according to VM's configuration.|
|prepare-volume|Utility that initializes and formats the disk backed by `private.img` file. It's registered to run on next system boot during QWT setup, if that feature is selected (it can't run *during* the setup because Xen block device drivers are not yet active). It in turn registers move-profiles (see below) to run at early boot.|
|relocate-dir|Utility that moves user profiles directory to the private disk. It's registered as an early boot native executable (similar to chkdsk) so it can run before any profile files are opened by some other process. Its log is in a fixed location: `c:\move-profiles.log` (it can't use our common logger library so none of the log settings apply).|

Updates
-------

When we publish a new QWT version, it's usually pushed to the `current-testing` or `unstable` repository first. To use versions from current-testing, run this in dom0:

`qubes-dom0-update --enablerepo=qubes-dom0-current-testing qubes-windows-tools`

That command will download a new QWT `.iso` from the testing repository. It goes without saying that you should **backup your VMs** before installing anything from testing repos.

