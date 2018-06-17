Restoring R3.2 Templates/Standalones To R4.0
===========================================================

Although restoring R3.2 AppVMs to R4.0 generally works with no problem, there are additional steps that need to be performed when doing the same with Templates and Standalone VMs.
If these steps are not done, the result is an inability to start programs from the Qubes menu for the restored VM.

1. After restoring your Template or StandaloneVM, go to Qube Settings -> Basic tab.
   Confirm Networking is set to one valid for your R4.0 system.
   Then, under the Advanced tab, confirm Virtualization Mode is `PVH`, and that Kernel is set to `default`.
2. From a dom0 prompt, enter `qvm-run <templatename> gnome-terminal` (or `xterm` if `gnome-terminal` is not installed).
3. Once the terminal window comes up, open another terminal window to a known good R4.0 template.
4. From the known good template's terminal, `qvm-copy /etc/yum.repos.d/qubes-r4.repo` to the restored template.
5. Do the same with `qvm-copy /etc/pki/rpm-gpg/RPM-GPG-KEY-qubes-4-*`.
6. On the restored template's terminal, `cd` into the `QubesIncoming` subfolder that contains the files you copied over from the known good R4.0 template, then in `su` mode:

~~~
cp qubes-r4.repo /etc/yum.repos.d/
rm /etc/yum.repos.d/qubes-r3.repo
rpm --import RPM-GPG-KEY-qubes-4-*
dnf update
### You will receive an error about qubes-core-agent transaction failed, so continue with:
dnf install qubes-core-agent qubes-kernel-vm-support
systemctl enable qubes-gui-agent
poweroff
~~~

You should then be able to use your restored Template's shortcuts as normal.
