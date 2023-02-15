# Replacing passwordless root with a dom0 prompt

For context, please see [passwordless root](https://www.qubes-os.org/doc/passwordless-root/).

While ITL supports the statement above, some Qubes users may wish to enable user/root isolation in VMs anyway.
We do not support it in any of our packages, but of course nothing is preventing the user from modifying his or her own system.
A list of steps to do so is provided here **without any guarantee of safety, accuracy, or completeness.
Proceed at your own risk.
Do not rely on this for extra security.**

1. Adding Dom0 "VMAuth" service:

    ```
    [root@dom0 /]# echo "/usr/bin/echo 1" >/etc/qubes-rpc/qubes.VMAuth
    [root@dom0 /]# echo "@anyvm dom0 ask,default_target=dom0" \
    >/etc/qubes-rpc/policy/qubes.VMAuth
    [root@dom0 /]# chmod +x /etc/qubes-rpc/qubes.VMAuth
    ```

   (Note: any VMs you would like still to have passwordless root access (e.g. Templates) can be specified in the second file with "\<vmname\> dom0 allow")

2. Configuring Fedora template to prompt Dom0 for any authorization request:
    - In `/etc/pam.d/system-auth`, replace all lines beginning with "auth" with these lines:

        ```
        auth  [success=1 default=ignore]  pam_exec.so seteuid /usr/lib/qubes/qrexec-client-vm dom0 qubes.VMAuth /bin/grep -q ^1$
        auth  requisite  pam_deny.so
        auth  required   pam_permit.so
        ```

    - Require authentication for sudo.
      Replace the first line of `/etc/sudoers.d/qubes` with:

        ```
        user ALL=(ALL) ALL
        ```

    - Disable PolKit's default-allow behavior:

        ```
        [root@fedora-20-x64]# rm /etc/polkit-1/rules.d/00-qubes-allow-all.rules
        [root@fedora-20-x64]# rm /etc/polkit-1/localauthority/50-local.d/qubes-allow-all.pkla
        ```

3. Configuring Debian/Whonix template to prompt Dom0 for any authorization request:
    - In `/etc/pam.d/common-auth`, replace all lines beginning with "auth" with these lines:

        ```
        auth  [success=1 default=ignore]  pam_exec.so seteuid /usr/lib/qubes/qrexec-client-vm dom0 qubes.VMAuth /bin/grep -q ^1$
        auth  requisite  pam_deny.so
        auth  required   pam_permit.so
        ```

    - Require authentication for sudo.
      Replace the first line of `/etc/sudoers.d/qubes` with:

        ```
        user ALL=(ALL) ALL
        ```

    - Disable PolKit's default-allow behavior:

        ```
        [root@debian-8]# rm /etc/polkit-1/rules.d/00-qubes-allow-all.rules
        [root@debian-8]# rm /etc/polkit-1/localauthority/50-local.d/qubes-allow-all.pkla
        ```

    - In `/etc/pam.d/su.qubes`, comment out this line near the bottom of the file:

        ```
        auth sufficient pam_permit.so
        ```

    - For Whonix, if prompts appear during boot, create `/etc/sudoers.d/zz99` and add these lines:

        ```
        ALL ALL=NOPASSWD: /usr/sbin/virt-what
        ALL ALL=NOPASSWD: /usr/sbin/service whonixcheck restart
        ALL ALL=NOPASSWD: /usr/sbin/service whonixcheck start
        ALL ALL=NOPASSWD: /usr/sbin/service whonixcheck stop
        ALL ALL=NOPASSWD: /usr/sbin/service whonixcheck status
        ```
