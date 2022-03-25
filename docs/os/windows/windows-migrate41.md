For Windows 10 and 11, there is a way to migrate backups created under Qubes R4.0 to R4.1. For this, the version of Qubes Windows Tools 4.1-67, created by @jevank tabit-pro / qubes-windows-tools-cross , has to be installed under Qubes R4.0, selecting the option to install the Xen PV disk driver, which emulates SCSI disks. For template VMs, the option to move user profiles may be selected, too. Then, the backup may be created, and this backup can be restored under Qubes R4.1, resulting in a VM well integrated into Qubes R4.1. If qvm-features <VMname> audio-model ich6 is set, Windows 11 even will have audio, although somewhat scratchy. (For Windows 10, I was so far not able to make audio work at all.)

While this is somewhat straightforward, things get difficult if QWT 4.0.1.3 was installed in the VM. Prior to installing version 4.1-65, the old version has to be removed, which can be quite tricky:

 - First, be sure that the automatic repair function is disabled. In a command window, execute bcdedit /set recoveryenabled NO, and check that this worked by issuing the command bcdedit, without parameters, again.
  
 - Now, uninstall QWT 4.0.1.3, using the Apps and Features function of Windows. This will most likely result in a crash.
  
 - Restart Windows again, possibly two or three times, until repair options are offered. By hitting the F8 key, select the restart menu, and there select a start in protected mode (in German, it's option number 4).
  
 - The system wil start gain, but in a rather useless way. Just shut it down, and reboot again.
  
 - Now Windows will start normally. Check in the Apps and Features display, if there are any Xen drivers left. If so, uninstall them.
  
 - In the Windows device manager, check if there is still a (probably non working) Xen PV disk device. If so, uninstall it. Otherwise, QWT 4.1-65 will not install.
  
 - In the Apps and Features display, check again, if the Xen drivers are removed. In my system, a Xen Bus Package (version 8.2.1.8) remains and cannot be removed, but does no harm. Any other Xen drivers should have disappeared.
  
 - Now, finally, after one additional reboot, Qubes Windows Tools 4.1-65 can be installed., and after one more reboot, the backup for R4.1 may be created.

