

## Note - Doc not finished yet! ##
This doc is reaching toward completion, however, has some errors that need correction first, as well as missing additions.

To-do:
- Fix kickstart template, it has a couple of issues, like creating user account creation that does conflict with first-boot, Qubes's initial-setup.
- Include template variants (for example to illustrate how they are modified, but this is a low-priority to-do).
- Sorting and including/excluding the proper packages that are recommended or optional (recommended packages are high priority, optional packages are low priority).
- Completting the sections that mention "may be included in the future" found a few places in the doc.
- Fixing bad tips, advices or KS-template layouts (proof-reading, requires extra study/read-up (must be done before official Qubes doc PR summit), or help from someone with insight).
- Fixing poor explanations (proof-reading).
- Fixing typo's and spelling errors, grammer etc, (proof-reading).
- Any feedback or contributions, like helping toward finishing the to-do, is very welcome and appreciated.


## Introduction ##
The purpose of kickstart files is to install an operation system from start to end with less, or no human interaction at all. A kickstart file is therefore essentially a pre-configuration of any settings you may normally need to adjust during a normal Linux install. Here you may find instructions on how to get started with Qubes OS and kickstart files.

In order to avoid confusion, please note that the use of the wording kickstarter template does not refer to Qubes templates, but rather a simple configuration file, which when loaded will semi or fully Autonomously install Qubes (or fedora/redhat/cent). 

<br />

**Typical uses**<br />
_The list is not exhausted, there may be other uses not listed here._
- Custom Qubes OS install.
  - Please note that the kickstarter template does not use installer-default kickstarter layout, a layout which by default also is incomplete (evident by the settings and values you normally adjust during normal install of the operation-system, but are autonomously configured here in the kickstarter file).
  - A greater degree of freedom to include/exclude commands, packages, or modify variables, which may otherwise not be changeable in the default installer. This gives you greater freedom to how you want your system to be set and organized.
- Swiftly installing or re-installing Qubes OS.
  - May be used to smoothly and quickly recover should dom0 be suspected of any compromises.
  - Various of scripts and automation can be included, to quickly restore everything in a clean state.
  - Switching, or frequently switching to new or different hardware. 
- Installing Qubes without graphic driver or card.
  - May be useful if needing to upgrade kernel, drivers, or other parts, without re-building Qubes installer or being forced to wait for a future Qubes version.
  - May be useful if installing Qubes from a remote location.
- Installing Qubes on a larger quantity of machines.
  - Typically wanted in organizations or companies, but may also be useful for some private power-users.
- Constructing a Qubes installer for a friend or family, who may be less advanced computer users.
  - Combine it with scripts, and they can easily recover themselves.
  - Scripts can also be used to automate other things, like restoring backups (maybe include a popup confirm message).
  - Kickstart file and all scripts can be put on the installer medium, other on a separate USB/medium. It makes it easier for the user if kept on a single device.

_Once you constructed your kickstart file, using them is be faster than normal Qubes install. It may take some time in the beginning to get proper habits and adjusting your personal settings, but consider it a time investment to save time and hassles in the future. Note new Qubes version release distributions may be slightly different, sometimes this may or may not require changes to your kickstart file. Be sure to keep your kickstart file secured, or check it against any changes done by 3rd party sources. However kickstart files are simple enough to quickly review before use, be sure you check everything, packages as well._
<br />


## Kickstart Template - Introduction to basics ##
_This section provides an introduction to the basics, you may skip if you're an average terminal user, and if you know how to load a kickstart file in grub._

This particular kickstart template introduced as a finished version in the example down below, will once initiated, install Qubes fully autonomously, without any human interaction to the selected drive. Be sure you put the correct drives and configurations. If you're not sure, then please disconnect other drives to ensure you do not mistakenly overwrite drives and their potential valuable data.

Users who have NVMe disks, please use `nvme0n1` instead of `sda`. Keep in mind if you got more than one NVMe drive, that this changes nvme0n**X**p**Y** in a similar fashion to normal sd**XY**. For example `nvme0n3` is equivalent to `sdc`, and `nvme0n3p4` is equivalent to `sdc4`.

Once installed, and Qubes is booting for the first time, and if you're asked to put a new username please use the same user-name in the Qubes initial-setup as you have put in your kickstart file.

Kickstart files are very easy to use and initiated. Whether on the installer medium or on a seperate medium, you just need to include the kickstart file location in the installer command line. For Qubes 4, press the Tab key at early Qubes installer boot stage, before you start the installer. Insert `ks=hd:sda:/ks.cfg`. Keep in mind it can be modified logically. If the ks.cfg is named differently, if its in a folder, if you're using a different device (like for example sdc4), or you're pulling it from a network location, etc. Please look it up if more is needed to config.

Copy and paste the below into a text editor, use nano, vi, or which text editor you prefer. Edit it to your needs, don't run it without first checking account details and drive install location. The name of the kickstart file is optional, but it must always end with `.cfg`. Naming it `ks.cfg` is recommended. Simply move it to anywhere the installer can reach it when booting, whether using the same medium or an extra separate medium.

You may use any terminal to identify a second medium's location. But remember if you unplug, or shutdown the machine after plugging in two or more medium devices, that their hierarchy may change. Sometimes a machines BIOS/UEFI may behave oddly in this manner. Keep this in mind if you cannot start/load the kickstart file. Installer will inform you before it starts making changes to the drive, if the kickstart file cannot be found, or if there are instructions it cannot understand in the kickstart file. 

## Kickstart Template - Adjusting your modifications ##
_All variables that needs changing, are labelled `change`, which include credentials, drive letters, timezones, language. Scroll below the template to find instructions on how to adjust values, revoming or including commands, package inclusion, etc._


```
# Kickstart file, preconfiguring the Qubes installer settings.

# Initializing installer
cdrom
text

# Protective measures, including redundancy measures.
ignoredisk --only-use=change
firewall
network  --hostname=dom0
authconfig --enableshadow --passalgo=sha512
sshpw --lock
rootpw --lock

# Account details
keyboard --vckeymap=change --xlayouts='change'
lang en_change.UTF-8
timezone change/change --isUtc
user --groups=wheel,qubes --name=change --password=change --iscryped

# Disk and Partitioning
bootloader --location=mbr --boot-drive=change --password=change --iscrypted
clearpart --all --initlabel --drives=change
autopart

# Boot settings
xconfig  --startxonboot
firstboot --enable


%packages
@^qubes-xfce

%end


%anaconda
pwpolicy root --minlen=0 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy user --minlen=0 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=0 --minquality=1 --notstrict --nochanges --emptyok
%end
```
<br />


## Adjusting credentials and encryption ##
- **All variables** that needs changing, are labelled `change`, which include credentials, drive letters, timezones, language.
- **Securing passwords** - The kickstart file can include passwords in plaintext, in which you simply write your password directly in the kickstarter file (not recommended), or with encrypted format (recommended). The ´--plaintext´ flag after passwords will instruct the use of plaintext in password databases, while ´--iscrypted´ flag after passwords will instruct to use hashed password values.
  - **Note that pre-hashing your passwords** is important if your kickstart file is ever discovered. It may be best to assume the worst, so it is recommended to always use --isencrypted flag and include the hashed password values.
  - **Basics of salt encryption** - Only creating hash values for your passwords is not enough to protect them, further protective measures are needed to increase the difficulty to gaining access, especially if you're using a short non-truly random password. This can be done by using salt encryption, which will generate a different hash value, even if you re-generate the same salt salted password again. Note that it will work on different machines even if the same password uses a different hash value, this is because the salted hash value includes the encrypted instructions that the encryption algorithm will read and understand, and ultimately in a more secure manner obtain the real hash for your password. Therefore it's fine to create your salted passwords elsewhere, whether on the same or a different secured system. Salt encrypted hashed passwords can only be understood by the legitimate programs, so be sure you do not mix them up with each others below. User login for grub2 encrypyion is always root. If you're curious to learn more, then you may find extra reading in the external sources headline further down below.
- **Grub2 encryption** - If you need to generate a hash password for the ´--iscrypted´ flag, then you can generate grub2 salted hash values in any secure terminal with grub2 installed. You may freely use any system, however make sure it is not compromised. Copy the whole line, starting from ´grub.pbkdf2.sha512...´.
- **Protecting the user-account** - Similar as for enhanced grub2 encryption, you may use ´--iscrypted´ to your user Linux profile, but keep in mind that Linux uses a different salt algorithm from grub2, so you'll need to adjust accordingly. Copy/paste this termianl to a clean dispVM, or use a clean fresh AppVM; `python -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'`. Just like with grub2, it'll ask for a password and a confirmation, before printing your salted hash. Copy/paste your hash value into the kickstart file user account password field.
- **Account name** - If you haven't already donr so, feel free to change it to any desired name.
- **LUKS disk encryption** - Will be included before official Qubes doc PR.
- **If you prefer not to encrypt grub2** - To disable, remove `--password=change --iscrypted` from the bootloader kickstarter line.
- **If you prefer not to encrypt disk** - Will be included before official Qubes doc PR.


## Adjusting drive letters ##
- All variables that needs changing, are labelled `change`, which include credentials, drive letters, timezones, language.
- Will be included before official Qubes doc PR.


## Adjusting timezones and language ## 
- All variables that needs changing, are labelled `change`, which include credentials, drive letters, timezones, language.
- Will be included before official Qubes doc PR.


## Adjusting included packages ## 
**Optional package list**
_List is not finished, will be updated._
```
@base
@base-x
@xfce-desktop-qubes
@xfce-extra-plugins
@xfce-media
@kde-desktop-qubes
@sound-basic
@fonts
@hardware-support
@qubes
@anaconda-tools
```

## Including or excluding kickstart commands ##
- Will be included before official Qubes doc PR.


## Kickstart uses gone wrong - Examples to avoid ##
  - Keep any fully autonomous kickstart USB's, or the medium of choice, locked-up, properly labelled, or avoid other scenarios where it may mistakenly be booted, by you or someone else.
    - It may be useful to have at least one manual option to select, before the installer starts on its own.
  - If you have other partitions or drives, be extremely careful and delicate.
    - Think at least twice before you boot from the kickstart file, so you don't overwrite anything important.
    - If you're not 100% sure of what you're doing, then pull out the other drives first. The kickstart file may install on the wrong drive or partitions if it is not set correctly.
  - When making semi kickstart files, be mindful of which settings that need to be disabled in order for the kickstart file to properly halt. 
<br />

## Qubes kickstart usage: Tips and tricks that may make a difference ##
- **Graphics issues**
  - If you're trying to get Qubes installed, for example on a machine without graphics, and you need sys-net and sys-firewall to update and repair dom0, then you may want to insert a network cable that does not require a password. 
  - If you do not have an RJ45 network port, then you can permanently or temporarily move the USB controller into your sys-net. Tell the Qubes installers initial setup at first boot, to make sys-net include sys-usb, so that sys-net holds your USB controllers. This way you can find your, or buy, a cheap USB to RJ45 network converter.
  - Instructions on how to enable password based networking without graphic drivers are possible, like wireless networking. But in its current form is not included in this doc. It may however be included in the future.
- **Updating Qubes offline (without network)**
  - Instructions on how to securely download updates on a different computer and install via USB or other mediums is possible. May be included in the future. 
- **Reaching dom0 Terminal**
  - Five different easy ways to get terminal on an empty system, to identity drive order/numbers.
  - Let the Qubes installer boot normally. When or if it fails, switch to tty2 or tty3 to get terminal. If this does not work (it may sometimes not be reachable on a failed boot), then proceed to next point below.
  - Put the number `3` after `quiet` in the boot Linux boot parameters. This boots the system into a non-graphical dom0 terminal (similar effect to using tty#).
  - Boot from the Qubes installer, pick troubleshoot, and then the option to rescue an existing Qubes system (even if there is no Qubes system installed). When requested to pick between 4-5 options, kick the skip to shell (if you only need to do `lsblk` for disk information, then this is sufficient), or continue into existing Qubes dom0 if you need it for other extra reasons.
  - Use a Live boot from a different distro, however unlike the above, this does not load most or all Qubes sub-systems, and also risks exposing dom0. This is the least desired method.
    - Preferably use another Linux distro you trust. For example Fedora live, the distro which dom0 is based on.
    - The Qubes Live (Alpha) medium may also work, however this is currently untested. Using any of the first 3 options above should be sufficient.
    
## Qubes booting: Tips and tricks that may make a difference ##
- **Reaching Qubes 4.0 boot installer configuration**
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
<br />


## Insight, guides, and other external resources ##
- **Resources** 
  - Official Anaconda kickstart developer documentation guide<br />
https://github.com/clumens/pykickstart/blob/master/docs/kickstart-docs.rst
  - Official Fedora Kickstart guide (Adjusted for fedora 27)<br />
https://docs.fedoraproject.org/f27/install-guide/advanced/Kickstart_Installations.html.
  - Official RedHat Documentation guide<br />
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/installation_guide/ch-kickstart2
  - Wiki - Salt Cryptography<br />
https://en.wikipedia.org/wiki/Salt_(cryptography)  

<br />

- **Qubes resources**
  - Here you may find the post this doc originally was inspired from.<br /> 
https://groups.google.com/forum/#!msg/qubes-users/-9qRHSkwfy8/CCx08nnTVEAJ

<br />


## Consideration before submitting updates to this doc ##
This doc is originally submitted by the fully independent volunteer group, Qubes Community Collaboration (QCC). You're naturally free to submit improvements of this doc to the Qubes OS staff for review on your own , but you can also choose to go through our channels at https://github.com/Qubes-Community/Contents/issues if you would like to improve the doc through the community collaboration. Feel free to start up an issue at QCC to discuss this doc and how to proceed. This potentially saves the Qubes OS staff time and resources, while still preserving transparency, and it helps improving doc PR summits further when worked out, improved, and shaped by a community. If its your first time submitting to GitHub but you would like to be independent, then we at QCC still encourage you get some GitHub experience through our channels first, before submitting anything official Qubes OS on your own. Credit to author(s) will always be preserved.
