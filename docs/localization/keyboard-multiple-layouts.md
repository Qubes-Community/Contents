Using multiple keyboard layouts
===============================

The [official Qubes OS faq entry](https://www.qubes-os.org/faq/#my-keyboard-layout-settings-are-not-behaving-correctly-what-should-i-do) only covers how to change the layout *globally* - ie. both for dom0 and VMs, with a *single* layout.

This document shows several ways of using *multiple* keyboard layouts and being able to *quickly* switch between them.

Recommended setup
-----------------

Run `setxkbmap` in *each* VM. Dom0 stays untouched (running `setxkbmap` in dom0 too will interfere with the VM's `setxkbmap` setup).

For instance the following command would alternate between the US English and the Bulgarian phonetic layout when pressing both shift keys:

~~~
setxkbmap -layout "us,bg(phonetic)" -option "grp:shifts_toggle"
~~~

To automatically run the `setxkbmap` command when the VM starts, add a `/etc/xdg/autostart/setxkbmap.desktop` file in the VM's *template* with the following content:

~~~
[Desktop Entry]
Name=Configure multiple keyboard layouts
Exec=setxkbmap -layout "us,bg(phonetic)" -option "grp:shifts_toggle"
Terminal=true
Type=Application
~~~

Note: for some reason, with `Terminal=false` the setxkbmap settings aren't applied until one runs `setxkbmap` without options in a terminal. Setting `Terminal=true` works around this problem, but you will notice a terminal flicker at startup.

If you prefer to have a per-vm setup rather than per-template, create a `/rw/config/setxkbmap.desktop` with the same content as above and add the following line to `/rw/config/rc.local`:

~~~
cp /rw/config/setxkbmap.desktop /etc/xdg/autostart
~~~

Note: the reason we can't put the `setxkbmap` command in the `rc.local` script is because the X server isn't running when `rc.local` is executed.

Alternatively, you could add the `setxkbmap` command to your profile's `.bashrc` file if you use terminals to start applications.


Alternative setups
------------------

- Configure a keyboard shortcut in dom0 that would run `qvm-run vname 'setxkbmap ...'`, where the VM is the one whose window is under the mouse pointer (using `xprop -id $(xdotool getactivewindow`) ). An advantage is that it doesn't require tweaking VMs or templates, but this is a bit convoluted and `qvm-run` is sometimes slow when the system is under heavy I/O usage, so the layout switch doesn't happen immediately which is annoying.
- Change the layout with `setxkbmap` *only in dom0*. This isn't optimal because:
    - there is no way to know which layout is used when typing the password in the xscreensaver's password field.
    - sometimes the keyboard layout would not be propagated to one of the VMs, requiring a reboot of the VM. 
- Once Qubes OS gains support for keyboard layout propagation from dom0 to VMs (see [this official issue](https://github.com/QubesOS/qubes-issues/issues/1396)) the desktop environment's keyboard layout switcher (eg. Xfce Keyboard Layout switcher) could be used instead of `setxkbmap`.  It is not clear however if this solution won't have the same issues as above.
- Change the layout in dom0 with `localectl`: it's a no-go as it requires a reboot


`Contributors: @taradiddles`
