# Setting default terminal settings for a TemplateVM

When you create a VM based on a TemplateVM, the `gnome-terminal` settings (font, color) are not inherited by default. This document describes how to set terminal defaults for all VMs *subsequently* created off a TemplateVM.

(Previously-created VMs are unaffected.)

This document only applies to `gnome-terminal` (the standard terminal)
and not XTerm, etc.

Thanks to `unman` on qubes-users for explaining how to do this.

## Define your defaults

In dom0:
`qvm-run MYTEMPLATE gnome-terminal`

In the terminal that pops up, adjust settings to your liking.

## Save settings template-wide

In the templateVM's terminal:
```
sudo mkdir -p /etc/skel/.config/dconf
sudo cp ~/.config/dconf/user /etc/skel/.config/dconf/
sudo reboot
```

Subsequently-created VMs should now use the chosen settings by default.

