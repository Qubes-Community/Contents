# Intel Integrated Graphics Troubleshooting

## Software Rendering or Video Lags

If you are experiencing this issue, you will see extremely slow graphics
updates.  You will be able to watch the screen and elements paint slowly from
top to bottom.  You can confirm this is the issue by looking for a line similar
to the following in your `/var/log/Xorg.0.log` file:

    [   131.769] (EE) AIGLX: reverting to software rendering

Newer versions of the Linux kernel have renamed the `i915.alpha_support=1`
option (which was originally called `i915.preliminary_hw_support=1`) to
`i915.force_probe=*`, so if you needed this kernel option in the past you will
have to rename it or add it to your configuration files (follow either GRUB2 or
EFI, not both):

 * GRUB2: `/etc/default/grub`, `GRUB_CMDLINE_LINUX` line and
   Rebuild grub config (`grub2-mkconfig -o /boot/grub2/grub.cfg`)

 * EFI: `/boot/efi/EFI/qubes/xen.cfg`, `kernel=` line(s)

If you are unsure as to which parameter works with your kernel, check whether
your kernel log from your latest boot has a message containing "i915: unknown
parameter".

## Fix tearing (glitches/artifacts/corruption/...)

By default Qubes OS uses `fbdev`, the framebuffer/modesetting driver. Without
compositing VM windows exhibit graphical artefacts (dom0 is unaffected).
Workarounds:

  * enable compositing; it is enabled by default in XFCE (if it was disabled for
    some reason, re-enabling it is done in "Window Manager Tweaks"; restarting
    `xfwm` isn't necessary). `i3wm`, `AwesomeWM` or `DWM` window managers don't
    provide compositing so their users would have to install a standalone
    compositing manager (the old
    [faq](https://faq.i3wm.org/question/3279/do-i-need-a-composite-manager-compton.1.html)
    mentions using `compton` but
    [`picom`](https://wiki.archlinux.org/title/Picom)
    is a more recent fork. Both are packaged in Fedora 32 and can be installed
    easily with `qubes-dom0-update`).

  * or switch to the `intel` driver. **Note: for some users the `intel` driver
    is unstable, triggering crashes/reboots !** - either reproducible (eg.
    moving a floating window to another monitor when using `i3wm`) to random and
    infrequent (eg. 1-3x a day with XFCE). In that case using the "UXA"
    acceleration method instead of the default "SNA" method seems to
    [fix](https://forum.qubes-os.org/t/qubesos-freeze-crash-and-reboots/12851/177)
    some crashes but [may
    introduce](https://forum.qubes-os.org/t/qubesos-freeze-crash-and-reboots/12851/178)
    other crashes.

    Create `/etc/X11/xorg.conf.d/20-intel.conf` with the following content:

    ```
    Section "Device"
        Identifier "Intel Graphics"
        Driver "Intel"
        # UXA is more stable than the default SNA for some users
        Option "AccelMethod" "UXA"
    EndSection
    ```

    A logout/login is then required.

    Intel's PSR (Panel Self Refresh) may also cause tearing issues; it can be
    disabled globally in GRUB2/EFI with the `i915.enable_psr=0` boot option. If
    this does fix tearing, a bad panel firmware was likely the cause.

## Finding out which of `intel` or `fbdev` driver is in use:

  * `grep -E 'LoadModule.*(fbdev|intel)"' /var/log/Xorg.0.log`; eg. for `intel`:

    ```
    (II) LoadModule: "intel"
    ```

  * or, `sudo lsof +D /usr/lib64/xorg/modules/drivers/` ; eg. for `fbdev`:

    ```
    Xorg    [...] /usr/lib64/xorg/modules/drivers/modesetting_drv.so
    ```

## IOMMU-related issues

Dom0 Kernels currently included in Qubes have issues related to VT-d (IOMMU) and
some versions of the integrated Intel Graphics Chip.  Depending on the specific
hardware / software combination the issues are quite wide ranging, from
apparently harmless log errors, to VM window refresh issues, to complete screen
corruption and crashes rendering the machine unusable with Qubes.

Such issues have been reported on at least the following machines:

* HP Elitebook 2540p
* Lenovo x201
* Lenovo x220
* Thinkpad T410
* Thinkpad T450s

Log errors only on :
* Librem 13v1
* Librem 15v2

The installer for Qubes 4.0 final has been updated to disable IOMMU for the
integrated intel graphics by default.  However, users of 3.2 may experience
issues on install or on kernel upgrades to versions higher than 3.18.x.

Disabling IOMMU for the integrated graphics chip is not a security issue, as the
device currently lives in dom0 and is not passed to a VM.  This behaviour is
planned to be changed as of Qubes 4.1, when passthrough capabilities will be
[required for the GUI
domain](https://github.com/QubesOS/qubes-issues/issues/2841).

### Workaround for existing systems with VT-d enabled (grub / legacy mode)

Edit the startup parameters for Xen:

1. Open a terminal in dom0
2. Edit `/etc/default/grub` (e.g. `sudo nano /etc/default/grub`)
3. Add to the line `GRUB_CMDLINE_XEN_DEFAULT` the setting `iommu=no-igfx`, save
   and quit
4. Commit the change with`sudo grub2-mkconfig --output /boot/grub2/grub.cfg`

### Workaround for existing systems with VT-d enabled (UEFI)

Edit the startup parameters for Xen:

1. Open a terminal in dom0
2. Edit `/boot/efi/EFI/qubes/xen.cfg` (e.g. `sudo nano
   /boot/efi/EFI/qubes/xen.cfg`)
3. Add to the line `options` the setting `iommu=no-igfx`, save and quit
