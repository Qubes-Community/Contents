DPI scaling
===========

Qubes OS passes on dom0's screen resolution to VMs (this can be seen in the output of `xrandr`) but doesn't pass on dom0's dpi value. Recent distributions have automatic scaling depending on the screen's resolution (eg. in fedora if the screen resolution is at least 192dpi and the screen height is greater than 1200 pixels) but for a variety of reasons one may have to set a custom dpi scaling value.


Dom0
----

The simplest way to set dpi scaling in dom0 is to use the desktop environment's custom dpi feature:

- Xfce: Qubes Menu → System Tools → Appearance → Fonts tab: Custom DPI setting: `xxx`
- KDE: Qubes Menu → System Settings → Font → Force font dpi: `xxx`
- i3: add `Xft.dpi: xxx` to `/home/user/.Xresources' in dom0

Replace `xxx` with a number that fits your setup and is a multiple of 6, as numbers that aren't sometimes result in annoying rounding errors that cause adjacent bitmap font sizes to not increment and decrement linearly.


VMs
---

The procedure for setting DPI scaling is different depending on whether gnome settings daemon is running or not:

- if the daemon is stopped/not installed, applications honor the `Xft.dpi` [X resource](https://en.wikipedia.org/wiki/X_resources) which we can then use for scaling.
- if the daemon is running (`/usr/libexec/gsd-xsettings` process in Fedora), applications are prevented from using the `Xft.dpi` resource and `dconf` values have to set.

Notes:
- the official `fedora-xx` template has the `gnome-settings-daemon` rpm installed by default while the `fedora-xx-minimal` template doesn't.
- DPI scaling with `xterm` (or any glib apps) requires the use of a xft font:
   - for `xterm`, ctrl - right click in the terminal's windows and select 'TrueType Fonts' (make sure you have such fonts installed).
   - or more generally, set the `faceName` Xresource, eg.:
   
       `*faceName: DejaVu Sans Mono:size=14:antialias=true`
   
       You may do so temporarily with the `xrdb -merge` command, or permanently in a `Xresources` file (see section below).


### VMs without gnome settings daemon ###

Get the current value of `Xft.dpi`:

~~~
xrdb -query | grep Xft.dpi
~~~

Test with a different dpi value: in a terminal issue the following command and then start an application to check that the menus/fonts' size is increased/decreased; replace '144' with the value set in dom0 (it's possible to set a different value in VMs though):

~~~
echo Xft.dpi: 144 | xrdb -merge
~~~

Once you found a value that fits your setup you'll likely want to permanently set the `Xft.dpi` resource. You can do so on a per-template (system-wide) or per-VM basis:

- add (or modify) `Xft.dpi: xxx` in the TemplateVM's Xresource file (`/etc/X11/Xresources` or `/etc/X11/Xresources/x11-common` for whonix-ws-template).
- or, add `Xft.dpi: xxx` to `$HOME/.Xresources` in each AppVM.


### VMs with gnome settings daemon ###

We'll set the `scaling-factor` and `text-scaling-factor` dconf values in the `org.gnome.desktop.interface` schema.

Get the current values:

~~~
gsettings get org.gnome.desktop.interface scaling-factor
gsettings get org.gnome.desktop.interface text-scaling-factor
~~~

Test with different values; notes:
- windows and menu/fonts should be resized dynamically
- when running the commands below the values will be automatically written to `$HOME/.config/dconf/user`
- replace `2` and `0.75` to suit your needs (`scaling-factor` **must** be an integer though)

~~~
gsettings set org.gnome.desktop.interface scaling-factor 2
gsettings set org.gnome.desktop.interface text-scaling-factor 0.75
~~~

If `gsd-xsettings` is running but nothing happens, examine the output of `dconf dump /`. If needed, reset any `xsettings` override:

~~~
gsettings reset org.gnome.settings-daemon.plugins.xsettings overrides
~~~

To store the dconf values system-wide - eg. when customizing templateVMs - copy the following text into `/etc/dconf/db/local.d/dpi` (replace `2` and `0.75` with your values):

~~~
[org/gnome/desktop/interface]
scaling-factor=uint32 2
text-scaling-factor=0.75
~~~

Then run `dconf update`.

Note: the `scaling-factor` and `text-scaling-factor` values might already be set in an AppVM's user profile, in which case they'll override the system-wide ones. To use system-wide values, reset the user values like so in the AppVM(s):

~~~
gsettings reset org.gnome.desktop.interface scaling-factor
gsettings reset org.gnome.desktop.interface text-scaling-factor
~~~


For more information on setting system-wide dconf values see [this page](https://help.gnome.org/admin/system-admin-guide/stable/dconf-custom-defaults.html.en).

# Troubleshooting

## Firefox and other GTK3 applications

Even when setting the correct dpi values, some applications might have very
small icons or similar elements. This usually happens in Firefox for example.

To mitigate this issue it is possible to set the `GDK_SCALE` and `GDK_DPI_SCALE`
variables as described
[here](https://wiki.archlinux.org/title/HiDPI#GDK_3_(GTK_3). To test these
values first, open a terminal and type:

~~~
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
firefox
~~~

You can try change the values for `GDK_SCALE` and `GDK_DPI_SCALE` to your
liking, but `GDK_SCALE` needs to be an integer value.

Once you confirmed that this is working, you can make these settings permanent
by creating a file `/etc/profile.d/dpi_GDK.sh` (ideally in the template VM) with
the following content and your own values:

~~~
#!/bin/sh

export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
~~~

Resources
---------
- ARCH Linux HiDPI wiki page: https://wiki.archlinux.org/index.php/HiDPI
- Gnome HiDPI wiki page: https://wiki.gnome.org/HowDoI/HiDpi
- Mozilla DPI-related Font Size Issues on Unix: https://www-archive.mozilla.org/unix/dpi.html
- Related official issue: https://github.com/QubesOS/qubes-issues/issues/1951

`Contributors: @taradiddles`
