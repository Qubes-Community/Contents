How to open URLs/files in other VMs
====================================

This document shows how to automatically open files/attachments/URLs in another VM, with or without user confirmation. This setup particularly suits "locked down" setups with restrictive firewalls like VMs dedicated to emails.

Naming convention:

- `srcVM` is the VM where the files/URLs are
- `dstVM` is the VM we want to open them in ; `dstVM` can be any VM type - a DispVM, a regular AppVM, a Whonix dvm, ...


Configuring `srcVM`
-------------------

There are quite a few approaches that one can choose to open files, each with their pros and cons. However the mechanism is the same for all of them: they use the `qubes.OpenInVM` and `qubes.OpenURL` [RPC services](https://www.qubes-os.org/doc/qrexec3/#qubes-rpc-services) (usually through the use of the `qvm-open-in-vm` and `qvm-open-in-dvm` scripts).


### Command-line ###

Save for copy/pasting URLs between VMs, the most basic - and less convenient - approach is to open files or URLs like so:

~~~
qvm-open-in-vm dstVM http://example.com
qvm-open-in-vm dstVM word.doc
~~~

Or, if opening in random dispVMs:

~~~
qvm-open-in-dvm http://example.com
qvm-open-in-dvm word.doc
~~~

Note: `qvm-open-in-dvm` is actually a wrapper to `qvm-open-in-vm`.


### Per application setup ###

Stepping up from the command line approach, a better solution would be to configure each application to use the `qvm-open-in-{vm,dvm}` scripts.


#### Thunderbird ####

In the case of Thunderbird, one has to define actions for opening attachements (see the [mozilla doc](http://kb.mozillazine.org/Actions_for_attachment_file_types), mainly section "Download Actions" settings"). Changing the way http and https URLs are opened requires tweaking config options though (see [this mozilla doc](http://kb.mozillazine.org/Changing_the_web_browser_invoked_by_Thunderbird)). Those changes can be made in Thunderbird's config editor, or by adding the following to `$HOME/.thunderbird/user.js` like so:

~~~
user_pref("network.protocol-handler.warn-external.http", true);
user_pref("network.protocol-handler.warn-external.https", true);
// http://kb.mozillazine.org/Network.protocol-handler.expose-all
user_pref("network.protocol-handler.expose-all", true);
~~~

Thunderbird will then ask which program to use the next time a link is opened. If `dstVM` should be a regular dispVM, choose `qvm-open-in-dvm`. Otherwise you'll have to create a wrapper since arguments cannot be passed to the program in Thunderbird's dialog. For instance, put the following in `$HOME/bin/thunderbird-url`, make it executable, and choose that script:

~~~
#!/bin/sh
qvm-open-in-vm dstVM "$@"
~~~


#### Firefox, Chrome/Chromium ####

Like Thunderbird those programs offer an option to define programs associated to a file (Mime) type. However this isn't really flexible - eg. one may want to open files in different dstVMs depending on the site's level of trust - in which case Raffaele Florio's [qubes-url-redirector](https://github.com/raffaeleflorio/qubes-url-redirector) add-on comes handy: links can be opened with a context menu and the add-on has a settings page embedded in the browser to customize itsdefault behavior, with support for whitelist regexes.


#### Vi ####

Put the following in `$HOME/.vimrc` to open URLs in `dstVM` (type `gx` when the cursor is over an URL):

~~~
let g:netrw_browsex_viewer = 'qvm-open-in-vm dstVM'
~~~


### Application independent setup ###

The section above relied on configuring *each* application; it is the most flexible approach but is overkill and time consuming when the same action/program should be used by all the applications in `srcVM`.

Providing the applications adheres to the freedesktop standard, defining a global action is straightforward:

- put the following in `~/.local/share/applications/browser_vm.desktop`

	~~~
	[Desktop Entry]
	Encoding=UTF-8
	Name=BrowserVM
	Exec=qvm-open-in-vm browser %u
	Terminal=false
	X-MultipleArgs=false
	Type=Application
	Categories=Network;WebBrowser;
	MimeType=x-scheme-handler/unknown;x-scheme-handler/about;text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
	~~~

- set xdg's "default browser" to the .desktop entry you've just created with `xdg-settings set default-web-browser browser_vm.desktop`

The same can be done with any Mime type (see `man xdg-mime` and `xdg-settings`).

**Caveat**: if dom0 default permissions are set to allow without user confirmation (see the "Configuring dom0 RPC permissions" section below), applications can leak data through the URL name despite `srcVM`'s restrictive firewall (you may notice that an URL has been open in `dstVM` but it would be too late).


Configuring dom0 RPC permissions
--------------------------------

When using `qvm-open-in-{vm,dvm}` scripts (`qubes.OpenInVM` and `qubes.OpenURL` RPC calls), one may choose if/when a user confirmation dialog should pop up, depending on the RPC call, and the `srcVM` / `dstVM` combo. See the [official doc](https://www.qubes-os.org/doc/rpc-policy/) for the proper syntax.


"Named, semi-permanent" dispVMs
-------------------------------

Opening things in dispVMs is the most secure approach, but the long starting time of dispVMs often gets in the way so users end up opening files/URLs in persistent VMs. An intermediate solution is to create a "semi-permanent" dispVM like so (replace `fedora-28-dvm` with the dvm template you want to use):

~~~
qvm-create -C DispVM -t fedora-28-dvm -l red dstVM
~~~

This VM works like a regular VM, with the difference that its private disk is wiped after it's powered off. However it doesn't "auto power off" like random dispVMs so it's up to the user to power off (and optionaly restart) the VM when he/she deems necessary.


Further considerations/caveats of dispVMs:

- Obviously, using dispVMs (whether random or "semi-permanent") for `dstVM` means that any change - saved bookmarks, application preferences, add-on update, ... - is lost at poweroff. Saving changes persistently requires updating the VM's templateVM, which may be cumbersome.
- inter-VM bookmark management might be eased with tools like [buku](https://github.com/jarun/Buku) (available in Fedora 28 repo - `dnf install buku`).

`Contributors/Credits: @Aekez, @raffaeleflorio, [Micah Lee](https://micahflee.com/2016/06/qubes-tip-opening-links-in-your-preferred-appvm/), @taradiddles`
