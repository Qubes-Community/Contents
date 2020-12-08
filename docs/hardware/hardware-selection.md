# Hardware Selection Tree #

Selecting the appropriate hardware for Qubes R4.0 can be a complex choice.
This document aims to simplify that.
Click on the links, read the supporting information if desired, reach a conclusion.

You may also want to check [these links](/docs/misc/iaq.md#xen-passthrough-compatible-video-cards) if you plan to use GPU passthrough (more suitable to desktop computers: laptop users will likely have a hard time finding a hardware combination that fits their needs since most of the supported graphics adapters are secondary adapters).

**Note** Qubes OS does not endorse any of the manufacturers or methods listed.

### Start here ###

Are you concerned about potential manufacturer [hardware backdoors](https://libreboot.org/faq.html#intel)?

[Yes](/docs/hardware/hardware-selection.md/#concerned)  
[No](/docs/hardware/hardware-selection.md/#unconcerned)

### Concerned ###

Are you concerned about [blobs](https://www.coreboot.org/Binary_situation) being used to initialize hardware?

[Yes](/docs/hardware/hardware-selection.md/#init)  
[No](/docs/hardware/hardware-selection.md/#mecleaner)  
[No, but I want AMD](/docs/hardware/hardware-selection.md/#amd)

### Init ###

Nearly all R4.0 capable systems require at least a CPU microcode blob, and often one for video BIOS.
However, there are still some options when it comes to running the [proprietary, unaudited code](https://www.coreboot.org/Intel_Management_Engine#Freedom_and_security_issues) for hardware initialization.
Do you want:

[AMD](/docs/hardware/hardware-selection.md/#amd)  
[Intel](/docs/hardware/hardware-selection.md/#intel)

### AMD ###

If you don't mind older/used hardware, there are some options if you do not want [PSP initialization](https://libreboot.org/faq.html#amd-platform-security-processor-psp).
All new AMD hardware comes with PSP.
In theory there is an option to partially disable it, but no motherboard/BIOS manufacturers have made it available yet.
Please update this if you are aware of any manufacturers that have.

Form factor?

[Laptop](/docs/hardware/hardware-selection.md/#amd-laptop)  
[Desktop](/docs/hardware/hardware-selection.md/#amd-desktop)

### AMD Laptop ###

DIY corebooted used [Lenovo G505s](https://www.coreboot.org/Board:lenovo/g505s) with [microcode patch](https://review.coreboot.org/#/c/coreboot/+/22843/).

### AMD Desktop ###

DIY or commercially available corebooted (or librebooted?) [KCMA-D8](https://www.coreboot.org/Board:asus/kcma-d8)/[KGPE-D16](https://www.coreboot.org/Board:asus/kgpe-d16).
Vikings is one vendor that appears to sell these.
If used with Opteron Series 2 processors, no microcode blob is required. However, it is still recommended to include current microcode due to vulnerabilities.

### Intel ###

Unfortunately, all R4.0 capable Intel hardware requires use of at least the [BUP portion](https://github.com/corna/me_cleaner/wiki/HAP-AltMeDisable-bit) of Intel ME.
[Weaknesses](https://mobile.twitter.com/rootkovska/status/938458875522666497) have been found in this proprietary, non-owner-controlled code.
There are some ways to restrict Intel ME after the initial BUP.

[Commercial](/docs/hardware/hardware-selection.md/#intel-commercial)  
[DIY](/docs/hardware/hardware-selection.md/#intel-diy)

### Intel Commercial ###

These vendors have systems available that partially disable Intel ME after the initial hardware initialization: Insurgo ([Qubes Certified](https://www.qubes-os.org/news/2019/07/18/insurgo-privacybeast-qubes-certification/)), System76, Purism, Dell.
Implementations vary, so research the vendors.
Prefer ones that use Heads or Coreboot instead of closed-source, [proprietary](https://www.kb.cert.org/vuls/id/758382) [UEFI firmware](https://www.securityweek.com/researchers-find-several-uefi-vulnerabilities).
Search the [HCL](https://www.qubes-os.org/hcl/) for a compatible system.
[Search the mailing list](https://www.mail-archive.com/qubes-users@googlegroups.com/) for additional reports.

### Intel DIY ###

Closed-source, proprietary UEFI firmware has its own [set](https://www.kb.cert.org/vuls/id/758382) of [vulnerabilities](https://www.securityweek.com/researchers-find-several-uefi-vulnerabilities).
Do these concern you?

[Yes](/docs/hardware/hardware-selection.md/#coreboot)  
[No](/docs/hardware/hardware-selection.md/#mecleaner)

### Coreboot ###

Cross reference [Coreboot](https://www.coreboot.org/Supported_Motherboards) capable systems with the [HCL](https://www.qubes-os.org/doc/hcl).
See also the [board freedom index](https://www.coreboot.org/Board_freedom_levels).
[Search the mailing list](https://www.mail-archive.com/qubes-users@googlegroups.com/) for additional reports.
Flash your system with Coreboot, including [ME_Cleaner](https://github.com/corna/me_cleaner).

[Heads](http://osresearch.net/) also offers some interesting capabilities beyond Coreboot, but has a smaller list of [supported boards](https://github.com/osresearch/heads/tree/master/boards).

### MECleaner ###

You can partially disable Intel ME while still running vendor UEFI firmware.
Search the [HCL](https://www.qubes-os.org/hcl/) for a compatible system.
[Search the mailing list](https://www.mail-archive.com/qubes-users@googlegroups.com/) for additional reports.
Follow the instructions [here](https://github.com/corna/me_cleaner).

### Unconcerned ###

Search the [HCL](https://www.qubes-os.org/hcl/) for an R4.0 compatible system.
[Search the mailing list](https://www.mail-archive.com/qubes-users@googlegroups.com/) for additional reports.

## Additional Notes ##
If selecting a desktop, you may also want to include and use a third party NIC in an expansion slot instead of the onboard Ethernet.
This is often not an option in laptops with manufacturer firmware due to the use of NIC whitelists, but you can use a USB based ethernet or wifi adapter instead with either desktop or laptop.
Optionally, disable DHCP on the subnet(s) your Qubes device connects to.
This will help avoid overt network communications from onboard management.
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
