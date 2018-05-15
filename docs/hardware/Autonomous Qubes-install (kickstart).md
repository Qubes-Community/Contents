## Introduction ##
The purpose of kickstart files is to install an operation system from start to end with less, or no human interaction at all. A kickstart file is therefore essentially a pre-configuration of any settings you may normally need to adjust during a normal Linux install. Here you may find instructions on how to get started with Qubes OS and kickstart files.

**Typical uses**
_List is not exhausted, there may be other uses not listed here. These are just the most common use-cases._
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

_Once you constructed your kickstart file, using them is faster than via normal install. It may take some time in the beginning to get proper habits and adjusting your personal settings, but consider it a time investment to save time and hassles in the future. Note new Qubes version release distributions may be slightly different, sometimes this may or may not require changes to your kickstart file. Be sure to keep your kickstart file secured, or check it against any changes done by 3rd party sources. However kickstart files are simple enough to quickly review before use, be sure you check everything, packages as well._
<br />


## Kickstart Template ##
_You may find the kickstart template if you scroll a bit further down. Please modify personal settings, drives to install to, partitioning, or other variables._

_This particular kickstart template will once initiated, install Qubes fully autonomously, without any human interaction, to the selected drive `sda` at /dev/sda, be sure you modify it to install on the correct drives. If you're not sure, then please disconnect other drives to ensure you do not mistakenly overwrite them._

_Users who have NVMe disks, please replace `sda` with `nvme0n1`. Keep in mind if you got more than one NVMe drive, that this changes nvme0n**X**p**Y** in a similar fashion to normal sd**XY**. For example `nvme0n3` is equivalent to `sdc`, and `nvme0n3p4` is equivalent to `sdc4`._

_Once installed, and Qubes is booting for the first time, and if you're asked to put a new username please use the same user-name in the Qubes initial-setup as you have put in your kickstart file._

_Kickstart files are very easy to use and initiated. Whether on the installer medium or on a seperate medium, you just need to include the kickstart file location in the installer command line. For Qubes 4, press the Tab key at early Qubes installer boot stage, before you start the installer. Insert `ks=hd:sda:/ks.cfg`. Keep in mind it can be modified logically. If the ks.cfg is named differently, if its in a folder, if you're using a different device (like for example sdc4), or you're pulling it from a network location, etc. Please look it up if more is needed to config._

_Copy and paste the below into a text editor, use nano, vi, or which text editor you prefer. Edit it to your needs, don't run it without first checking account details and drive install location. The name of the kickstart file is optional, but it must always end with `.cfg`. Naming it `ks.cfg` is recommended. Simply move it to anywhere the installer can reach it when booting, whether using the same medium or an extra separate medium._

_You may use any terminal to identify a second medium's location. But remember if you unplug, or shutdown the machine after plugging in two or more medium devices, that their hierarchy may change. Sometimes a machines BIOS/UEFI may behave oddly in this manner. Keep this in mind if you cannot start/load the kickstart file. Installer will inform you before it starts making changes to the drive, if the kickstart file cannot be found, or if there are instructions it cannot understand in the kickstart file._ 

```
# Kickstart file, preconfiguring the Qubes installer settings.

# Initializing installer
auth --enableshadow --passalgo=sha512
cdrom
text

# Protective measures
ignoredisk --only-use=sda
firewall --service=ssh
network  --hostname=dom0
rootpw --lock

# Account details
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
timezone Europe/London --isUtc
user --groups=wheel,qubes --name=change-name-here --password=change-pwd-here

# Disk and Partitioning
bootloader --location=mbr --boot-drive=sda
clearpart --all --initlabel --drives=sda
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

## Extra configurations ## 
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


## Kickstart uses gone wrong - Examples to avoid ##
  - Keep any fully autonomous kickstart USB's, or the medium of choice, locked-up, properly labelled, or avoid other scenarios where it may mistakenly be booted, by you or someone else.
    - It may be useful to have at least one manual option to select, before the installer starts on its own.
  - If you have other partitions or drives, be extremely careful and delicate.
    - Think at least twice before you boot from the kickstart file, so you don't overwrite anything important.
    - If you're not 100% sure of what you're doing, then pull out the other drives first. The kickstart file may install on the wrong drive or partitions if it is not set correctly.
  - When making semi kickstart files, be mindful of which settings that need to be disabled in order for the kickstart file to properly halt. 
<br />

## Tips and tricks that may make a difference ##
- If you're trying to get Qubes installed, for example on a machine without graphics, and you need sys-net and sys-firewall to update and repair dom0, then you may want to insert a network cable that does not require a password. 
  - If you do not have an RJ45 network port, then you can permanently or temporarily move the USB controller into your sys-net. Tell the Qubes installers initial setup at first boot, to make sys-net include sys-usb, so that sys-net holds your USB controllers. This way you can find your, or buy, a cheap USB to RJ45 network converter.
  - Instructions on how to enable password based networking without graphic drivers are possible, like wireless networking. But in its current form is not included in this doc. It may however be included in the future.
- Instructions on how to securely download updates on a different computer and install via USB or other mediums is possible. May be included in the future. 
- Five different easy ways to get terminal on an empty system, to identity drive order/numbers.
  - Let the Qubes installer boot normally. When or if it fails, switch to tty2 or tty3 to get terminal. If this does not work (it may sometimes not be reachable on a failed boot), then proceed to next point below.
  - Put the number `3` after `quiet` in the boot Linux boot parameters. This boots the system into a non-graphical dom0 terminal (similar effect to using tty#).
  - Boot from the Qubes installer, pick troubleshoot, and then the option to rescue an existing Qubes system (even if there is no Qubes system installed). When requested to pick between 4-5 options, kick the skip to shell (if you only need to do `lsblk` for disk information, then this is sufficient), or continue into existing Qubes dom0 if you need it for other extra reasons.
  - Use a Live boot from a different distro, however unlike the above, this does not load most or all Qubes sub-systems, and also risks exposing dom0. This is the least desired method.
    - Preferably use another Linux distro you trust. For example Fedora live, the distro which dom0 is based on.
    - The Qubes Live (Alpha) medium may also work, however this is currently untested. Using any of the first 3 options above should be sufficient.

<br />


## Insight, guides, and other external resources ##
- **Resources** 
  - Official Anaconda kickstart developer documentation guide 
https://github.com/clumens/pykickstart/blob/master/docs/kickstart-docs.rst
  - Official Fedora Kickstart guide (Adjusted for fedora 27) 
https://docs.fedoraproject.org/f27/install-guide/advanced/Kickstart_Installations.html.
  - Official RedHat Documentation guide 
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/installation_guide/ch-kickstart2
<br />


## Kickstart files are sometimes controversial in culture ##
Some label them for advanced users only (being too difficult to use), while others label them for noobs, or newbs, only. The beliefs, or statements, are contradictionary to each others. In reality though, kickstart files can be useful for anyone, whether made for someone who is not very skilled with computers, or useful for someone who is an advanced computer user. So it is best to keep it that way, kickstart files are useful tools that everyone can use in some way or another, don't let silly culture conjuncture influence what you use, if it is useful to you. Furthermore, anyone who have the skill level to install and use Qubes on their own, can probably also build and use their own kickstart files. They're not as scary as they might seem at first. 
<br />

## Consideration before submitting updates to this doc ##
This doc is originally submitted by the independent volunteer group Qubes Community Collaboration. You're free to submit improvements on your own, but you can also go through our channels at https://github.com/Qubes-Community/Contents/issues if you would like to improve the doc with our volunteer collaboration. If its your first time submitting docs and you would like to be be independent, then we still recommend you get some experience through our channels first, before submitting anything officially for quality review by the Qubes staff. Of course you're also welcome to join our volunteer efforts as a collaboration.
