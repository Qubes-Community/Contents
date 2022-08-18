# Building the 'archlinux-minimal' Qubes template

## Read first
This is a community guide, not an official guide. So please, first read the below official guides:
- [Qubes-builder](https://www.qubes-os.org/doc/qubes-builder/)
- [Qubes-builder-details](https://www.qubes-os.org/doc/qubes-builder-details/)
- [Qubes-builder doc directory](https://github.com/marmarek/qubes-builder/tree/master/doc)
- [Qubes templates config](https://github.com/QubesOS/qubes-template-configs/blob/master/README.md)

Only if the above guides don't work for you, then try this one.

Arch Linux is a [rolling](https://en.wikipedia.org/wiki/Rolling_release)
distribution, making it fragile. In fact, with always the latest versions, the
ArchLinux packages meet first the new problems. So it's better to first try to
build templates or packages for Fedora or Debian.

Also read:
- the *Debugging the build process* below section
- the [ArchLinux known issues](https://github.com/QubesOS/qubes-issues/labels/C%3A%20Arch%20Linux) with Qubes-OS

These instructions are known to work for QubesOS 4.1.

## Steps

### 1. Create a qubes-builder AppVM

Create an AppVM, based on the last Fedora TemplateVM, named for example
*qubes-builder* or *build-archlinux* (see below).

![arch-template-01](/attachment/wiki/ArchlinuxTemplate/arch-template-01.png)

> **The StandaloneVM type cannot build the Arch Linux (minimal or not) template
> currently, as its Makefiles and Scripts only fully accomodate for the AppVM
> type's set of filesystem permissions!**

In the qubes settings set at least 15GB of space in the Qube's private storage
and create the AppVM by clicking OK. 

![arch-template-02](/attachment/wiki/ArchlinuxTemplate/arch-template-02.png)

Then run the following commands in dom0 to set the VCPUs and memory for the
AppVM:

```console
qvm-prefs build-archlinux2 vcpus $(nproc)
qvm-prefs build-archlinux2 memory 4000
qvm-prefs build-archlinux2 maxmem 4000
```

> **`nproc` specified the number of CPU logical cores it detected, meaning
> memory usage will increase for compilations that utilize the additional
> logical cores. For building the 'archlinux-minimal' template, 4000MB should be
> plenty.**

### 2. Downloading and verifying the integrity of the "Qubes Automated Build System"

> **Open a terminal in the qubes-builder AppVM that you just created. All
following commands are supposed to typed there, unless stated otherwise.**

Set terminal size to 30 lines and 100 columns; ensures text from **qubes-builder**'s setup script isn't cut-off.

```console
resize -s 30 100
```

Install initial dependencies without user confirmation.

```console
sudo dnf install -y git make
```

Import and verify the Qubes master key (have a look
[here](https://www.qubes-os.org/security/verifying-signatures/) to understand
the purpose of the verification).

```console
gpg2 --import /usr/share/qubes/qubes-master-key.asc
gpg2 --edit-key 0x427F11FD0FAA4B080123F01CDDFA1A3E36879494
```

In the interactive gnupg shell that opens following the last command, you type
in `fpr` and hit enter to show the fingerprint. Afterwards you type `trust` and
`5` to set the trust level to 'ultimately'. Afterwards you need to confirm your
selection with 'y' and save and exit via `quit`. It should look something like
this:

```console
gpg> fpr
pub   rsa4096/DDFA1A3E36879494 2010-04-01 Qubes Master Signing Key
 Primary key fingerprint: 427F 11FD 0FAA 4B08 0123  F01C DDFA 1A3E 3687 9494

gpg> trust
pub  rsa4096/DDFA1A3E36879494
     created: 2010-04-01  expires: never       usage: SC  
     trust: unknown       validity: unknown
[ unknown] (1). Qubes Master Signing Key

Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5
Do you really want to set this key to ultimate trust? (y/N) y

pub  rsa4096/DDFA1A3E36879494
     created: 2010-04-01  expires: never       usage: SC  
     trust: ultimate      validity: unknown
[ unknown] (1). Qubes Master Signing Key
Please note that the shown key validity is not necessarily correct
unless you restart the program.

gpg> quit
```

Download then import the Qubes developers' keys:

```console
curl -O https://keys.qubes-os.org/keys/qubes-developers-keys.asc
gpg2 --import qubes-developers-keys.asc
```

Download the latest stable `qubes-builder` repository:

```console
git clone https://github.com/QubesOS/qubes-builder.git $HOME/qubes-builder/
```

Verify the integrity of the `qubes-builder` repository:

```console
cd $HOME/qubes-builder/
git tag -v $(git describe)
```

The output should contain something like this

```console
gpg: Good signature from "Marek Marczykowski-Górecki (Qubes OS signing key) <marmarek@invisiblethingslab.com>" [full]
```

The verifcation succeeded if you see a good signature as seen above.

Now install the remaining dependencies:

```console
make install-deps
```

### 3. Configure the `builder.conf` file

> **The manual way is copying an example config like
> `$HOME/qubes-builder/example-configs/qubes-os-r4.0.conf` to
> `$HOME/qubes-builder/builder.conf`, then editing that copied file.**

<details><summary>Setup script method (easier to begin with)</summary>

Run the `setup` script located in `$HOME/qubes-builder/`:

```console
./setup
```

Install the missing dependencies, by pressing **y**.

![arch-template-04](/attachment/wiki/ArchlinuxTemplate/arch-template-04.png)

Import the 'Qubes-Master-Signing-key.asc' by selecting **Yes**. The setup script
downloads and confirms this key to that of the key on Qubes OS website.

![arch-template-05](/attachment/wiki/ArchlinuxTemplate/arch-template-05.png)

Confirm again with **Yes**.

![arch-template-06](/attachment/wiki/ArchlinuxTemplate/arch-template-06.png)

Choose which Qubes release to build templates for, e.g. **4.1** (use space key to select) and
hit enter to accept selection.

![arch-template-07](/attachment/wiki/ArchlinuxTemplate/arch-template-07.png)

Choose source repos to use to build packages. Select **QubesOS/qubes-** to get the
default stable repo.

![arch-template-08](/attachment/wiki/ArchlinuxTemplate/arch-template-08.png)

Select **Yes** for fast git cloning.

> **'No' is for reusing the same building environment on a StandaloneVM (not an
> AppVM, as we have used here); a "shallow clone" (depth equal one) is [a bad
> choice for reusable
> environments](https://github.blog/2020-12-21-get-up-to-speed-with-partial-clone-and-shallow-clone/).**

![arch-template-09](/attachment/wiki/ArchlinuxTemplate/arch-template-09.png)

Do **not select** any pre-built package repository to build the template
yourself.

![arch-template-10](/attachment/wiki/ArchlinuxTemplate/arch-template-10.png)

Select **Yes** to only build the template.

![arch-template-11](/attachment/wiki/ArchlinuxTemplate/arch-template-11.png)

Template distribution selection offers choices of distributions to build.
Deselect everything (navigating to entry and hitting space) and select
**archlinux-minimal** and confirm by hitting enter.

> **Using 'archlinux' may introduce more failed compiles based on additional
> Qubes components you may not even need. You can install them later manually
> instead.**

![arch-template-12](/attachment/wiki/ArchlinuxTemplate/arch-template-12.png)

The builder plugins selection offers choices of builder plugins to compile.
Deselect everything (navigating to entry and hitting space) and select
**builder-archlinux** and confirm by hitting enter.

![arch-template-13](/attachment/wiki/ArchlinuxTemplate/arch-template-13.png)

Select **Yes** to fetch additional source files needed for the chosen builder
plugins.

![arch-template-14](/attachment/wiki/ArchlinuxTemplate/arch-template-14.png)

Press Enter/Return while **OK** is selected to exit.

![arch-template-15](/attachment/wiki/ArchlinuxTemplate/arch-template-15.png)

Go directly to [step 4 below](#4-make-all-the-required-qubes-components) to
proceed with the build process.

</details>

<details><summary>Manually creating `builder.conf` (for experienced users)</summary>

```console
ls -l $HOME/qubes-builder/example-configs
```
```sh
#!/bin/sh
VER=r4.0
if [ -f example-configs/qubes-os-$VER.conf ]; then
        cp example-configs/qubes-os-$VER.conf "${PWD}"/builder.conf
        sed -i 's/DISTS_VM ?=.*/DISTS_VM ?= archlinux+minimal/' "${PWD}"/builder.conf
        sed -i 's/#COMPONENTS += builder-archlinux/COMPONENTS += builder-archlinux/g' "${PWD}"/builder.conf
        sed -i 's/#BUILDER_PLUGINS += builder-archlinux/BUILDER_PLUGINS += builder-archlinux/g' "${PWD}"/builder.conf
    else
    # Can execute this script outside of `$HOME/qubes-builder` and it still works as intended.
        cp example-configs/qubes-os-$VER.conf "${0%/*}"/builder.conf
        sed -i 's/DISTS_VM ?=.*/DISTS_VM ?= archlinux+minimal/' "${0%/*}"/builder.conf
        sed -i 's/#COMPONENTS += builder-archlinux/COMPONENTS += builder-archlinux/g' "${0%/*}"/builder.conf
        sed -i 's/#BUILDER_PLUGINS += builder-archlinux/BUILDER_PLUGINS += builder-archlinux/g' "${0%/*}"/builder.conf
fi
```

</details>

### 4. Make all the required Qubes components

At first the following components need to be build:

```console
make remount
make install-deps
make get-sources
```

> **These commands above should get executed every time you restart the
> qubes-builder AppVM, because these change are lost after a reboot of the VM!**

Now build all Qubes components (this can take a long time) via 

```console
make qubes-vm
```

<details><summary>Debugging: commands to 'make' every Qubes component manually</summary>

If `make qubes-vm` fails, you can try to pinpoint the problem by building the
components one by one manually.

```console
make vmm-xen-vm
make core-vchan-xen-vm
make core-qubesdb-vm
make core-qrexec-vm
make linux-utils-vm
make core-agent-linux-vm
make gui-common-vm
make gui-agent-linux-vm
make app-linux-split-gpg-vm
make app-linux-usb-proxy-vm
make meta-packages-vm
```

</details>

### 5. Build the actual Arch Linux template

```console
make template
```

### 6. Transfer the template into Dom0

You need to ensure the rpm template is in the `noarch` directory:

```console
ls $HOME/qubes-builder/qubes-src/linux-template-builder/rpm/noarch
qubes-template-archlinux-*.*.*-*.noarch.rpm
```

Transfer the qubes-template-archlinux rpm into Dom0

> **File transfering to Dom0 is considered unsafe. You accept full
> responsibility if Dom0 is compromised due to this file transfer.**
  
Follow the
[copying-to-dom0](https://www.qubes-os.org/doc/how-to-copy-from-dom0/#copying-to-dom0)
official guide. Afterwards, read [how to install software in
dom0](https://www.qubes-os.org/doc/how-to-install-software-in-dom0/) and install
the rpm with `sudo dnf install <rpm_file>`.

If the build process went smoothly, the 'archlinux-minimal' template will be listed in Qubes Manager.

___
## Debugging the build process

Arch Linux is a [rolling](https://en.wikipedia.org/wiki/Rolling_release) distro, making it a fragile template for Qubes.
It's important to understand how to debug Qubes templates, fix, then do a pull request.

See below explanations and examples which (we hope) will help you to solve the common problems, and do a pull request with your solution.

[neowutran's semi-automated 'archlinux-minimal' Qubes template builder script](https://github.com/Qubes-Community/Contents/blob/master/code/OS-administration/build-archlinux.sh). \
The most important part about this script is where to add custom code that is not in the Qubes OS repositories.

<!-- Whoever made these lines need to clarify what this is about.

After the command:
```console
$ make get-sources
```
And before the command:
```console
$ make qubes-vm
```
-->

You can put your custom code by replacing the `qubes-src/` directories.
For example: 
```console
$ rm -Rf "$directory/qubes-src/gui-agent-linux/"
$ cp -R ~/qubes-gui-agent-linux "$directory/qubes-src/gui-agent-linux"
```

### UseCase : Xorg

Launch the build:
```console
$ ./build_arch.sh
```
It crashed with the following output:
```
Makefile:202: target 'builder-archlinux.get-sources' given more than once in the same rule
Makefile:204: target 'builder-archlinux.get-sources-extra' given more than once in the same rule
Makefile:225: target 'builder-archlinux-vm' given more than once in the same rule
Makefile:237: target 'builder-archlinux-dom0' given more than once in the same rule
Makefile:585: target 'builder-archlinux.grep' given more than once in the same rule
-> Building template archlinux (logfile: build-logs/template-archlinux.log)...
make: *** [Makefile:319: template-local-archlinux+minimal] Error 1
```
Let's check `build-logs/template-archlinux.log`:
```
--> Finishing installation of qubes packages...
resolving dependencies...
warning: cannot resolve "xorg-server<1.20.7", a dependency of "qubes-vm-gui"
:: The following package cannot be upgraded due to unresolvable dependencies:
      qubes-vm-gui

:: Do you want to skip the above package for this upgrade? [y/N] error: failed to prepare transaction (could not satisfy dependencies)

:: unable to satisfy dependency 'xorg-server<1.20.7' required by qubes-vm-gui
make[1]: *** [Makefile:64: rootimg-build] Error 1
```
The xorg-server package was probably updated to a version greater than 1.20.7.
Let's search what is the current version of xorg-server... Currently, it is **1.20.7-1**.
Neither a fix nor a minor version change is likely to break things.
So let's find the dependency for "**xorg-server<1.20.7**" and change it to "**xorg-server<1.21**".

> **rg stands for [ripgrep](https://github.com/BurntSushi/ripgrep), an alternative to GNU grep.**

```console
$ rg -iuu "xorg-server<1.20.7" ./qubes-builder/qubes-src/ 2> /dev/null
./qubes-builder/qubes-src/gui-agent-linux/archlinux/PKGBUILD
55:		'xorg-server>=1.20.4' 'xorg-server<1.20.7'
```
So the **/archlinux/PKGBUILD** file of the repository "qubes-gui-agent-linux" requires modification. \
Git clone "qubes-gui-agent-linux", git checkout to the correct branch (example: `release4.0` instead of master), and then attempt a modification on the **/archlinux/PKGBUILD** file. \
In your building script, right before the "make qubes-vm", remove the existing "gui-agent-linux" folder and replace it with your own.
Example, add this to the script:
```sh
rm -Rf "~/qubes-builder/qubes-src/gui-agent-linux/"
cp -R ~/qubes-gui-agent-linux "~/qubes-builder/qubes-src/gui-agent-linux"
```
Then try building the template.
If the template built successfully and works as expected, do a pull request on GitHub to share your fix(es). 

### UseCase: Missing pulsecore error when building the gui-agent-linux

```console
$ make
module-vchan-sink.c:64:10: fatal error: pulsecore/core-error.h: No such file or directory
   64 | #include <pulsecore/core-error.h>
      |          ^```````````````~~~
```
This error is caused by Arch Linux having a newer version of PulseAudio than the PulseAudio headers imported by the Qubes team.
It can be fixed by downloading the new version of the headers, and rebuilding.
This solution prevents any breaking API changes from going silently unnoticed.

> **Replace 14.2 with your version (with additional suffixes such as -PATCH removed)**

```console
$ git clone https://github.com/pulseaudio/pulseaudio.git $HOME/git/pulseaudio
$ cd $HOME/git/pulseaudio
$ git checkout v14.2
$ cd $HOME/qubes-builder/qubes-src/gui-agent-linux/pulse/
$ cp -r $HOME/git/pulseaudio/src/pulsecore/pulsecore-14.2/ #symlink didn't work
```
Or simply use the old headers and hope nothing breaks unexpectedly later:
```console
$ cd $HOME/qubes-builder/qubes-src/gui-agent-linux/pulse/
$ ln -sr pulsecore-14.1 pulsecore-14.2
```

### Known issues

### xenstore-read: xs_open: permission denied
If the following error appears:
<details><summary>Click here to show error message</summary>

```
+ umask 022
+ cd /home/user/qubes-builder/qubes-src/linux-template-builder
+ rm -rf /home/user/qubes-builder/qubes-src/linux-template-builder/rpmbuild/BUILDROOT/qubes-template-archlinux-4.0.6-202111300407.noarch
+ RPM_EC=0
++ jobs -p
+ exit 0
xenstore-read: xs_open: Permission denied
```

</details>

During the template building process an error ocurred, corrupting the group id of the /dev/xen/* files.
To fix this you'll need to assign the correct permissions, so you'll have to enter the following <b> while `make template` is running: </b>
```console
sudo chgrp qubes /dev/xen/*
```




## Debugging the Qubes-ArchLinux runtime
If you are able to launch a terminal and execute command, utilize your Arch-fu to fix the issue. \
If unable to launch a terminal, shutdown the qube, create a new DisposableVM, [mount an Arch Linux ISO in a DisposableVM](https://www.qubes-os.org/doc/mount-lvm-image/), chroot to it, and then use your Arch-fu. \
Example of this kind of debugging [that happened on Reddit](https://old.reddit.com/r/Qubes/comments/eg50ne/built_arch_linux_template_and_installed_but_app/).

### Question
Hello.
I just built an 'archlinux' template and moved it to Dom0, then installed the template.
Afterwards I tried to open a terminal in the 'archlinux' TemplateVM, but it shows nothing. \
Can you please check this logs and please tell me what is wrong. Thanks.

I searched the word "Failed" and found few:
```
[0m] Failed to start..... Initialize and mount /rw and /home.... see 'systemctl status qubes-mount-dirs.service' for details
[0m] Failed unmounting.... /usr/lib/modules....
... msg='unit=qubes-mount-dirs comm="systemd" exe="/usr/lib/systemd/systemd" hostname=" addr=? terminal=? res=failed'
tsc: Fast TSC calibration failed
failed to mount moving /dev to /sysroot/dev: Invalid argument
failed to mount moving /proc to /sysroot/dev: Invalid argument
failed to mount moving /sys to /sysroot/dev: Invalid argument
failed to mount moving /run to /sysroot/dev: Invalid argument
when I tried to run terminal, in log says
audit: type=1131 audit(some number): pid=1 uid=0 auid=some number ses=some number msg='unit=systemd=tmpfiles-clean cmm="systemd" exe="/usr/lib/systemd" hostname=? addr=? terminal? res=success'
```
I tried to rebuild the 'archlinux' template and got the same issue. \
How can I debug this Qube?

### Answer
The issue came from a systemd unit named "qubes-mount-dirs". We want to know more about that. \
We can't execute command into the qube, so let's shut it down.
Then, we mount the 'archlinux' root disk into a DisposableVM (
[mount_lvm_image.sh](https://github.com/Qubes-Community/Contents/blob/master/code/OS-administration/mount_lvm_image.sh)
& [mount-lvm-image](https://www.qubes-os.org/doc/mount-lvm-image/) )
```console
$ ./mount_lvm_image.sh /dev/qubes_dom0/vm-archlinux-minimal-root fedora-dvm
```
In the newly created DisposableVM, mount that (disk) image and {ch}ange {root}.
```console
# mount /dev/xvdi3 /mnt
# chroot /mnt
```
Then check its systemd-journald entries:
```
[root@disp9786 /]# journalctl -u qubes-mount-dirs
-- Logs begin at Fri 2019-12-27 09:26:15 CET, end at Fri 2019-12-27 09:27:58 CET. --
Dec 27 09:26:16 archlinux systemd[1]: Starting Initialize and mount /rw and /home...
Dec 27 09:26:16 archlinux mount-dirs.sh[420]: /usr/lib/qubes/init/setup-rwdev.sh: line 16: cmp: command not found
Dec 27 09:26:16 archlinux mount-dirs.sh[414]: Private device management: checking /dev/xvdb
Dec 27 09:26:16 archlinux mount-dirs.sh[414]: Private device management: fsck.ext4 /dev/xvdb failed:
Dec 27 09:26:16 archlinux mount-dirs.sh[414]: fsck.ext4: Bad magic number in super-block while trying to open /dev/xvdb
Dec 27 09:26:16 archlinux mount-dirs.sh[414]: /dev/xvdb:
Dec 27 09:26:16 archlinux mount-dirs.sh[414]: The superblock could not be read or does not describe a valid ext2/ext3/ext4
Dec 27 09:26:16 archlinux mount-dirs.sh[414]: filesystem.  If the device is valid and it really contains an ext2/ext3/ext4
Dec 27 09:26:16 archlinux mount-dirs.sh[414]: filesystem (and not swap or ufs or something else), then the superblock
Dec 27 09:26:16 archlinux mount-dirs.sh[414]: is corrupt, and you might try running e2fsck with an alternate superblock:
Dec 27 09:26:16 archlinux mount-dirs.sh[414]:     e2fsck -b 8193 <device>
Dec 27 09:26:16 archlinux mount-dirs.sh[414]:  or
Dec 27 09:26:16 archlinux mount-dirs.sh[414]:     e2fsck -b 32768 <device>
Dec 27 09:26:16 archlinux mount-dirs.sh[430]: mount: /rw: wrong fs type, bad option, bad superblock on /dev/xvdb, missing codepage     or helper program, or other error.
Dec 27 09:26:16 archlinux systemd[1]: qubes-mount-dirs.service: Main process exited, code=exited, status=32/n/a
Dec 27 09:26:16 archlinux systemd[1]: qubes-mount-dirs.service: Failed with result 'exit-code'.
Dec 27 09:26:16 archlinux systemd[1]: Failed to start Initialize and mount /rw and /home.
-- Reboot --
Dec 27 09:26:54 archlinux mount-dirs.sh[423]: /usr/lib/qubes/init/setup-rwdev.sh: line 16: cmp: command not found
Dec 27 09:26:54 archlinux mount-dirs.sh[416]: Private device management: checking /dev/xvdb
Dec 27 09:26:54 archlinux systemd[1]: Starting Initialize and mount /rw and /home...
Dec 27 09:26:54 archlinux mount-dirs.sh[416]: Private device management: fsck.ext4 /dev/xvdb failed:
Dec 27 09:26:54 archlinux mount-dirs.sh[416]: fsck.ext4: Bad magic number in super-block while trying to open /dev/xvdb
Dec 27 09:26:54 archlinux mount-dirs.sh[416]: /dev/xvdb:
Dec 27 09:26:54 archlinux mount-dirs.sh[416]: The superblock could not be read or does not describe a valid ext2/ext3/ext4
Dec 27 09:26:54 archlinux mount-dirs.sh[416]: filesystem.  If the device is valid and it really contains an ext2/ext3/ext4
Dec 27 09:26:54 archlinux mount-dirs.sh[416]: filesystem (and not swap or ufs or something else), then the superblock
Dec 27 09:26:54 archlinux mount-dirs.sh[416]: is corrupt, and you might try running e2fsck with an alternate superblock:
Dec 27 09:26:54 archlinux mount-dirs.sh[416]:     e2fsck -b 8193 <device>
Dec 27 09:26:54 archlinux mount-dirs.sh[416]:  or
Dec 27 09:26:54 archlinux mount-dirs.sh[416]:     e2fsck -b 32768 <device>
Dec 27 09:26:54 archlinux mount-dirs.sh[432]: mount: /rw: wrong fs type, bad option, bad superblock on /dev/xvdb, missing codepage or helper program, or other error.
Dec 27 09:26:54 archlinux systemd[1]: qubes-mount-dirs.service: Main process exited, code=exited, status=32/n/a
Dec 27 09:26:54 archlinux systemd[1]: qubes-mount-dirs.service: Failed with result 'exit-code'.
Dec 27 09:26:54 archlinux systemd[1]: Failed to start Initialize and mount /rw and /home.
```
The most important line was: 
```console
/usr/lib/qubes/init/setup-rwdev.sh: line 16: cmp: command not found
```
Let's edit `setup-rwdev.sh`:
```sh
#!/bin/sh
set -e
dev=/dev/xvdb
max_size=1073741824  # check at most 1 GiB
if [ -e "$dev" ] ; then
    # The private /dev/xvdb device is present.
    # Check if private.img (xvdb) is empty/all zeros
    private_size=$(( $(blockdev --getsz "$dev") * 512))
    if [ $private_size -gt $max_size ]; then
        private_size=$max_size
    fi
    if cmp --bytes $private_size "$dev" /dev/zero >/dev/null && { blkid -p "$dev" >/dev/null; [ $? -eq 2 ]; }; then
        # The device is empty; create a ext4 filesystem
        echo "Virgin boot of the VM: creating private.img filesystem on $dev" >&2
        if ! content=$(mkfs.ext4 -m 0 -q "$dev" 2>&1) ; then
            echo "Virgin boot of the VM: creation of private.img on $dev failed:" >&2
            echo "$content" >&2
            echo "Virgin boot of the VM: aborting" >&2
            exit 1
        fi
    fi
fi
```
`cmp` definitely needs to be working. So the binary `cmp` is missing, let's find it:
```console
# pacman -Fy cmp
```
It's located in ***`core/diffutils`***, and for some (currently) unknown reason is not installed.
Let's modify the 'archlinux' template builder to add this package. Modify the files `qubes-builder/qubes-src/builder-archlinux/script/packages` to add the ***`diffutils`***, and rebuild the template.
Why this package was not installed in the first place? I am unsure. It could be that it was a dependency of the package ***`xf86dgaproto`*** that was removed few days ago, but I don't have the PKGBUILD of this package since it was deleted, so can't confirm. It can be something else too.
I rebuild the template with those modification, and it is working as expected.
I will send a pull request. Does someone have a better idea on "Why ***`diffutils`*** was not installed in the first place?" ?
[The commit](https://github.com/neowutran/qubes-builder-archlinux/commit/09a435fcc6bdcb19144d198ea20f7a27826c1d80)

___
## Creating an ArchLinux repository
Once the template have been build, you could use the generated archlinux packages to create your own archlinux repository for QubesOS packages.
You need to:
* Sign the packages with your GPG key
* Host the packages on your HTTP server 

I will assume that you already have a working HTTP server. \
So you need to sign the packages and transmit everything to the qubes that will upload them to your HTTP server.
The script `update-remote-repo.sh` of the "qubes-builder-archlinux" repository can do that.
Below, an example of code that sign the packages + template rpm file, and transmit everything to another qube.
```sh
$directory/qubes-src/builder-archlinux/update-remote-repo.sh
rpmfile=$(ls -1 $directory/qubes-src/linux-template-builder/rpm/noarch/*.rpm | head -n 1)
qubes-gpg-client-wrapper --detach-sign $rpmfile > $rpmfile.sig
qvm-copy $rpmfile
qvm-copy $rpmfile.sig
qvm-copy $directory/qubes-packages-mirror-repo/vm-archlinux/pkgs/
```
Upload everything to your HTTP server, and you are good. 
You can now modify the file `/etc/pacman.d/99-qubes-repository-4.0.conf` in your archlinux template to use your repository.
Example of content for this file (**replace the server URL with your own**): 
```console
[qubes]
Server = https://neowutran.ovh/qubes/vm-archlinux/pkgs
```
### About the package `qubes-vm-keyring`
The goal of this package was to add a **`pacman`** source for the Qubes OS packages, and to set its maintainer GPG key as trusted.
**There are binary packages available (unofficially):**
* https://neowutran.ovh/qubes/vm-archlinux/pkgs (go up a directory for an Arch Linux template built for Qubes OS 4.0.3 only)

If the Qubes OS developers start providing binary packages themselves, the GPG key and fingerprint of the new maintainer(s) might be added in the files below: 
* https://github.com/QubesOS/qubes-core-agent-linux/blob/master/archlinux/PKGBUILD-keyring-keys
* https://github.com/QubesOS/qubes-core-agent-linux/blob/master/archlinux/archlinux/PKGBUILD-keyring-trusted

___
### StandaloneVM stuff
Having a StandaloneVM for building Qube distro templates would be safer than an AppVM, and wouldn't require reinstalling all dependencies after each VM reboot. \
But if this wasn't chosen over AppVM by default, there must be downsides to a StandaloneVM I'm unable to think of from a lack of knowledge with Qubes' inner workings.

### Was in 3.
#### Open a terminal in Dom0
```console
# sed -e 's/nodev/dev/g' -e 's/nosuid/suid/g' -i /etc/fstab
```
```console
# qvm-shutdown --wait build-archlinux2;qvm-start build-archlinux2
```

### Was in 5.
Finding if anything in `qubes-builder/` is currently mounted.
```console
$ findmnt
```
`$`Edit: `$HOME/cleanup.sh`
```sh
#!/bin/sh
sudo umount --lazy --recursive "$HOME/qubes-builder/chroot-vm-archlinux/*/"
sudo umount --lazy --recursive "$HOME/qubes-builder/cache/archlinux/bootstrap/*/"
sudo umount --lazy --recursive "$HOME/qubes-builder/qubes-src/linux-template-builder/*/"
sudo rm -Rf "$HOME/qubes-builder/chroot-vm-archlinux/"
sudo rm -Rf "$HOME/qubes-builder/cache/"
```
> **Since --lazy is used, rebooting the VM afterwards will prevent strange problems.**

___
