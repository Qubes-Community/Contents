Language Localization
=====================

Enable UTF-8 in dom0 title bars
-------------------------

You can enable UTF-8 characters in the title bar for all (non-Windows) qubes or on a per-qube basis. For an individual qube, this can be done using the Qube Manager's `Advanced` tab or, in a `dom0` terminal, via the command

   `qvm-features <VMname> gui-allow-utf8-titles true`

To change this given GUI option globally, set this feature in the Qube Manager's `Global Settings` plane, which will apply to all qubes using the GuiVM under which Qube Manager is running (usually `dom0`, or possibly in one of the alternative GuiVMs `sys-gui` or `sys-gui-gpu`). To set this property globally for all qubes running under a certain GuiVM, e.g. `dom0`, use the command

   `qvm-features dom0 gui-default-allow-utf8-titles true`

or accordingly.

**Note:** This does not work for Windows qubes.

Changing the language of dom0
-----------------------------

In order to install an additional language in `dom0`, e.g. German: In a `dom0` terminal, execute

   `sudo qubes-dom0-update langpacks-de`

Then reboot.

Before logging in, the task panel will show - usually far to the right - the current language, e.g. `C.UTF-8`. Clicking on this value will open a menu where you can select the GUI language, i.e. the interface language of Qubes used in `dom0` and in the menus, like Whiskers. Note, however, that the language of some Qubes utilities like the Qube Manager does not change, and any Templates and AppVMs based on these Templates retain their language.

This need only be done once; the selected language survives logging out and reboot.

Set up keyboard and system language/locale separately
-----------------------------------------------------

If you want a separate setting for dom0 language and time (e.g. to have the week start on Monday in system calendar),
edit the `/etc/locale.conf` file in dom0.

You can set different variables there, e.g. LANG variable is reponsible for the system language, and LC_TIME for calendar 
settings. For example, the following settings will have the system in English, but have the calendar week start on Monday.

      LANG="en_US.UTF-8"
      LC_TIME="en_IE.utf8"

To see the changes, you need to reboot.

Changing the language of Templates and the AppVMs based on them
---------------------------------------------------------------

To change the language of existing Templates, you have to install the language packs in these Templates.

For Fedora-based Templates, this is done (for German as an example) via

   `sudo dnf install langpacks-de`

For debian-based Templates, the corresponding command is

   `sudo apt-get install language-pack-de language-pack-gnome-de language-pack-de-base language-pack-gnome-de-base`

For other languages, the corresponding code has to be used, e.g. `fr` for French. After installing a language, it has to be selected/enabled via the settings of the Template.

New Templates will be installed in their default language, usually English, and they have to be changed just like existing Templates. This could be alleviated by installing a “clean” Template from the repository, with nothing but the needed language packs before starting to create a new template–clone using one of these languages. For instance, when you need a totally new Template (e.g., Debian 12 when it comes out), you’ll have to create debian-12-de and regenerate all other Templates from that.

The language of Windows Templates is determined at the installation of the operating system and can be changed afterwards if the installed edition is a multi-language edition; otherwise the language stays fixed.

AppVMs started after this change will inherit the language from the corresponsing Template.

How to set up pinyin input in Qubes
-----------------------------------

The pinyin input method will be installed in a TemplateVM to make it available after restarts and across multiple AppVMs.

1. In a TemplateVM, install `ibus-pinyin` via the package manager or terminal.
   If the template is Fedora-based, run `sudo dnf install ibus-pinyin`.
   If the template is Debian-based, run `sudo apt install ibus-pinyin`

2. Shut down the TemplateVM.

3. Start or restart an AppVM based on the template in which you installed `ibus-pinyin` and open a terminal.

4. Run `ibus-setup`.

5. You will likely get an error message telling you to paste the following into your bashrc:

        export GTK_IM_MODULE=ibus
        export XMODIFIERS=@im=ibus
        export QT_IM_MODULE=ibus

   Copy the text into your `~/.bashrc` file with your favorite text editor.
   You will need to do this for any AppVM in which you wish to use pinyin input.

6. Set up ibus input as you like using the graphical menu (add pinyin or intelligent pinyin to selections).
   You can bring the menu back by issuing `ibus-setup` from a terminal.

7. Set up your shortcut for switching between inputs.
   By default it is super-space.

If `ibus-pinyin` is not enabled when you restart one of these AppVMs, open a terminal and run `ibus-setup` to activate ibus again.

For further discussion, see [this qubes-users thread](https://groups.google.com/forum/#!searchin/qubes-users/languge/qubes-users/VcNPlhdgVQM/iF9PqSzayacJ).
