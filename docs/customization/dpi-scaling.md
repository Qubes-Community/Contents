DPI scaling
===========

Qubes OS passes on dom0's screen resolution to VMs (this can be seen in the output of `xrandr`) but doesn't pass on dom0's dpi value. Recent distributions have automatic scaling depending on the screen's resolution (eg. in fedora if the vertical resolution is greater than 1200px) but for a variety of reasons one may have to set a custom dpi scaling value.


Dom0
----

The simplest way to set dpi scaling in dom0 is to use the desktop environment's custom dpi feature:

- Xfce: Qubes Menu → System Tools → Appearance → Fonts tab: Custom DPI setting: `xxx`
- KDE: Qubes Menu → System Settings → Font → Force font dpi: `xxx`

Replace `xxx` with a number that fits your setup and is a multiple of 6, as numbers that aren't sometimes result in annoying rounding errors that cause adjacent bitmap font sizes to not increment and decrement linearly.


VMs
---

The procedure for setting DPI scaling depends on the presence of the `/usr/libexec/gsd-xsettings` daemon, usually provided by the `gnome-settings-daemon` package:

- without `/usr/libexec/gsd-xsettings` running, applications honor the `Xft.dpi` [X resource](https://en.wikipedia.org/wiki/X_resources), which we can use for scaling.
- with `/usr/libexec/gsd-xsettings` running, applications are prevented from using the `Xft.dpi` resource so gnome specific commands have to used.

Notes:
- the official `fedora-xx` template has `gnome-settings-daemon` installed by default while the `fedora-xx-minimal` template doesn't.
- DPI scaling with `xterm` (or any glib apps) requires the use of a xft font:
   - for `xterm`, ctrl - right click in the terminal's windows and select 'TrueType Fonts' (make sure you have such fonts installed).
   - or more generally, set the `faceName` Xresource, eg.:
   
       `*faceName: DejaVu Sans Mono:size=14:antialias=true`
   
       You may do so temporarily with the `xrdb -merge` command, or permanently in a `Xresources` file (see section below).


### VMs without gsd-xsettings ###

Get the current value of `Xft.dpi`:

~~~
xrdb -query | grep Xft.dpi
~~~

Test with a different dpi value: in a terminal issue the following command and then start an application to check that the menus/fonts' size is increased/decreased; replace '144' with the value set in dom0 (it's possible to set a different value in VMs though):

~~~
echo Xft.dpi: 144 | xrdb -merge
~~~

Once you found a value that fits your setup you'll likely want to permanently set the `Xft.dpi` resource. You can do so on a per-template or per-VM basis:

- add (or modify) `Xft.dpi: xxx` in the TemplateVM's Xresource file (`/etc/X11/Xresources` or `/etc/X11/Xresources/x11-common` for whonix-ws-template).
- or, add `Xft.dpi: xxx` to `$HOME/.Xresources` in each AppVM.


### VMs with gsd-xsettings ### 


Use the `gsettings` command (replace `2` and `0.75` to suit your needs ; the first value must be an integer though):

~~~
gsettings set org.gnome.desktop.interface scaling-factor 2
gsettings set org.gnome.desktop.interface text-scaling-factor 0.75
~~~


Resources
---------
- ARCH Linux HiDPI page: https://wiki.archlinux.org/index.php/HiDPI
- Related official issue: https://github.com/QubesOS/qubes-issues/issues/1951
- Mozilla DPI-related Font Size Issues on Unix: https://www-archive.mozilla.org/unix/dpi.html

`Contributors: @taradiddles`
