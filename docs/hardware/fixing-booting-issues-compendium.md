
## Note - Doc is not finished and under construction ##
This doc is in its early development phase, and will be continuerly added to, and is intended for multiple users to add in their own install/boot issue experiences, or adding problems/solutions to issues that is found and collected from other users.

**To-do table**
- To do the to-do table (uhue, the irony, but in a hurry atm).
- Feel free to add to the to-do list though, or the doc itself below.


## Fixes to booting and installing issues compendium ##

**Reaching Qubes 4.0 boot installer configuration**
- In Qubes 4.0, and maybe 4.1. although it may have been fixed in the upcoming 4.1. version, you will need to use the `Tab` key instead of the `e` key like you normally do to change settings in the Grub boot installer menu.
  - It looks different to Grub, here little changes except for the bottom of the screen, which will include a brief couple of lines where you can change settings.
  - You may include the kickstart script here, and you can also do other settings changes like blacklisting drivers, or enabling drivers, and so on.
- **Some BIOS cause irritating issues, and how to avoid/fix**
  - One such scenario are if you cannot find your boot device despite it having worked previously, and settings have not changed in BIOS. If this happens, it often works to enter the BIOS, making no changes, and choose "save and exit". This refreshes the BIOS settings, and the drive can be booted.
  - Other times the BIOS may "reset" on its own without any warning, for example if you change hardware or at any time had temporairly removed any hardware (internal hardware, not counting USB devices, etc.). If you're having issues, make sure this is not the case by checking the BIOS settings. Off-topic, but worth including: The BIOS reset can also lead to disabling the IOMMU security settings if it is disabled in the default factury profile, and if you don't notice the BIOS reset, then this will leave your system becoming vulnurable. Please consider using Anti-Evil-Maid (AEM) to protect against these, but be mindful of the trade-off's of using AEM. [You can find official information about AEM here](https://www.qubes-os.org/doc/anti-evil-maid/).
- **Disabling Secure Boot, and hidden bugs**
  - Currently Qubes OS do not hold a secure boot key/license, so secure boot will not work with Qubes.
    - The Qubes OS staff have stated that they do not endorse secure boot, because it has short-comings and issues.
    - Currently your only option is to disable secure-boot.
  - Please remember that other installed dual-boot systems that depend on secure-boot may stop working if you disable secure-boot. This isn't only Windows, but include some Linux distributions that have choosen to support secure-boot.
    - In general it's also discouraged to run dual-boot systems, whether Linux, Windows or other, because it weakens the isolation protection that dom0 seeks to maximize.
      - High profile targets, or just unlucky badly infected systems, make dual-boot a significant threath to dom0, encryption is not enough (anything in various device firmware (like drive firmwares), BIOS/UEFI, or Grub itself, can be infected and exploited). Keeping your system clean, preferably without previous history of previous system installs, is desireable (If this is all new to you, then you're encouraged to read up on general and common Qubes security).
  - A hidden bug appears on "some" motherboards/BIOS versions, where it may not always be enough to just disable secure-boot, but also deleting the secure-boot keys (if available).
    - Remember to check the motherboard manual if you can restore the keys on a later point if you need them later!
    - It is unknown how common the bug is, it's probably not widespread, but it has at least one anecdotal case on a desktop ASUS Z170 Pro motherboard.
- **Unsupported graphic-cards and dual graphic-cards**
  - You gain little or no benifit by putting a powerful graphiccard in dom0, unless your goal is many screens, or extreme resolutions. Most modern internal graphic cards can easily run a 4K screen, or a couple of dual-screens in 2K-3K graphic resolution.
  - Some dual-graphic motherboards have adjustable BIOS settings that affects both internal and external, like shared memory or simiar effects. Be sure you check these settings if you have trouble booting.
    - Do not do this if you do not know what you're doing, changing such settings could give you a black screen at boot or damage your system (especially on systems that have overclocking features, whether you intend to overclock or not, such BIOS typically have many more settings outside the overclocking section, which may or may not be dangerous for your systems well-being to change). 
    - One way to fix bad BIOS settings that cause a black-screen, that normally works and assuming no damage was caused, is to temporarily remove the CMOS battery on the motherboard to reset it (or switch jumpers, see your motherboard manual).
    - If you have a laptop or an exotic system then it may be hard to reach such a reset functionality, but similar most laptops have simple BIOS's, which as a result means it may be less easily set to a bad setting requiring a reset (but still be careful).
  - If you use an unsurported graphic-card by Qubes OS, then it requires troubleshooting (like the above kickstart graphic fix tip), or it may not be possilbe (missing drivers/support for fedora systems).
  - (Nvidia/Intel graphics): If you have a dual-graphic system (Onboard-Intel/External-Nvidia), then it may be easier to go with the on-board Intel graphics which is better supported than nvidia drivers. The nouveau drivers are preferred, sincenthe offical nvidia drivers are closed source Proprietary code and shouldn't be trusted in the dom0 environment, and can also be quite troublesome to install as well. 
  - (AMD graphics): The onboard/external graphic cards by AMD which tend to be more supported on Linux in general, although it is uncertain if its better supported than onboard intel graphics (Onboard intel may probably generally be a bit better than AMD, but many AMD cards seem to work quite neatly as well).
    - More effort is being put into making AMD graphics work in Linux, for example the Linux Kernel 4.17 will include support for AMDGPU in the kernel itself, where you no longer need to provide a newer linux-firmware package and then enable it yourself in the kernel settings during Grub start-up, but from then onwards, should just work out-of-the-box.
    - This presumes the right version of AMDGPU is in the kernel (from 4.17. upwards) and that your AMD graphic-card isn't too new for the kernel (reasonable to assume within 6 months to 12 months), or possibly too old.
  - Currently dom0 graphics is not passthrough but is run directly in the domo environment, and therefore does not need to have passthrough capability, however, and be mindful, that this may or may not change in Qubes 4.1. where graphics may become isolated from dom0, which may potentially bring new passthrough graphic issues to life.
  - This new isolation feature may possibly be optional, just like PV/HVM/PVH, sys-usb isolation, and similar user-choices, depending on what the developers finds to be the best approach to avoid hardware conflicts, so keep this possibility in mind for the future.
