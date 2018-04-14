DPI scaling
===========

Qubes OS passes on dom0's screen resolution to VMs (this can be seen in the output of `xrandr`) but doesn't pass on dom0's dpi value. Recent distributions have automatic scaling depending on the screen's resolution (eg. in fedora if the vertical resolution is greater than 1200px) but for a variety of reasons one may have to set a custom dpi scaling value.


Dom0
----

The simplest way to set dpi scaling in dom0 is to use the desktop environment's custom dpi feature:

- Xfce: Qubes Menu → System Tools → Appearance → Fonts tab: Custom DPI setting: `xxx`
- KDE: Qubes Menu → System Settings → Font → Force font dpi: `xxx`


VMs
---

We'll make use of the `Xft.dpi` [X resource](https://en.wikipedia.org/wiki/X_resources) in VMs. Most (all ?) toolkits and applications honor it so it is the prefered way to set dpi scaling instead of using toolkit-specific features.

Get the current value of `Xft.dpi`:

~~~
xrdb -query | grep Xft.dpi
~~~

Test with a different dpi value: in a terminal issue the following command and then start an application to check that the menus/fonts' size is increased/decreased (replace '144' accordingly with a number that is a multiple of 6, or even 12, as numbers that aren't sometimes result in annoying rounding errors that cause adjacent bitmap font sizes to not increment and decrement linearly):

~~~
echo Xft.dpi: 144 | xrdb -merge
~~~

Once you found a value that fits your setup you'll likely want to permanently set the dpi resource. You can do so on a per-template or per-VM basis:
- add a `Xft.dpi: xxx` line to the TemplateVM's Xresource file (`/etc/X11/Xresources` or `/etc/X11/Xresources/x11-common` for whonix-ws-template).
- or, add a `Xft.dpi: xxx` line to .Xresources file in *each* VM's user profile (`$HOME/.Xresources`)


Note for R3.2: the `Xft.dpi` resource should be used by applications; if you have issues you may want to try the following (replace `2` and `0.75` accordingly):

~~~
gsettings set org.gnome.desktop.interface scaling-factor 2
gsettings set org.gnome.desktop.interface text-scaling-factor 0.75
~~~


Resources
---------

Related official issue: https://github.com/QubesOS/qubes-issues/issues/1951


Contributors: @taraddidles
