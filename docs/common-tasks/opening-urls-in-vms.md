How to open URLs/files in other VMs
===================================

This document describes how to open files/attachments/URLs in another VM, with or without user confirmation. This setup particularly suits "locked down" setups with restrictive firewalls like VMs dedicated to emails.

Naming convention:

- `srcVM` is the VM where the files/URLs are
- `dstVM` is the VM we want to open them in ; `dstVM` can be any VM type - a DispVM, a regular AppVM, a Whonix dvm, ...


Configuring dom0 RPC permissions
--------------------------------

There are different approaches to open files and URLs in other VMs but they all rely on the `qubes.OpenInVM` and `qubes.OpenURL` [RPC services](https://www.qubes-os.org/doc/qrexec3/#qubes-rpc-services), usually through the use of the `qvm-open-in-vm` and `qvm-open-in-dvm` shell scripts in `srcVM`.

Qubes RPC policies can be configured based on the service name and `srcVM` (+ optionally `dstVM`) to allow or deny the use of the service, or to ask user confirmation with a popup list of destination VMs. See the [official documentation](https://www.qubes-os.org/doc/rpc-policy/).
In the case that an `allow` policy is configured (ie. no user confirmation/popup dialog) *and* that different destination VMs are to be used - eg. depending on the URL/file (site's level of trust, protocol, file [MIME](https://en.wikipedia.org/wiki/Media_type) type, ... - it is up to `srcVM` to specify the right `dstVM`, with the help of a custom wrapper to the `qvm-open-in-vm` script, or a specific application add-on.


Configuring `srcVM`
-------------------

The subsections below list various approaches. 


### Inter-VM copy/paste and file copy ###

This approach is obvious and is the simplest one:

- URLs: [copy/paste](https://www.qubes-os.org/doc/copy-paste/) the link in `dstVM`.
- Files: [copy](https://www.qubes-os.org/doc/copying-files/) the file to `dstVM` (provided that `qubes.Filecopy` RPC service's policy allows it - it does by default), and open it from there.


### Command-line ###

Another obvious and basic approach - but less convenient - is to open files or URLs in a terminal in `srcVM`:

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

Most applications provide a way to select a given program to use for opening specific URL/file (MIME) types. We can use that feature to select the `/usr/bin/qvm-open-in-{vm,dvm}` scripts instead of the default programs.

The subsections below show how to configure popular applications.


#### Thunderbird ####

Opening attachements: "actions" must be defined for opening attachements; see [this document](http://kb.mozillazine.org/Actions_for_attachment_file_types), section "Download Actions" settings".

Opening URLs: changing the way http and https URLs are opened requires tweaking configuration options; see [this](http://kb.mozillazine.org/Changing_the_web_browser_invoked_by_Thunderbird) and [this](http://kb.mozillazine.org/Network.protocol-handler.expose-all) document for more information. Those changes can be made in Thunderbird's built-in config editor, or by adding the following lines to `$HOME/.thunderbird/user.js`:

~~~
user_pref("network.protocol-handler.warn-external.http", true);
user_pref("network.protocol-handler.warn-external.https", true);
user_pref("network.protocol-handler.expose-all", true);
~~~

Thunderbird will then ask which program to use the next time a link is opened. If `dstVM` is a standard (random) dispVM, choose `/usr/bin/qvm-open-in-dvm`. Otherwise you'll have to create a wrapper to `qvm-open-in-vm` since arguments cannot be passed to programs selected in Thunderbird's dialog gui. For instance, put the following text in `$HOME/bin/thunderbird-open-url`, make it executable, and select that program when asked which program to use:

~~~
#!/bin/sh
qvm-open-in-vm dstVM "$@"
~~~


#### Firefox, Chrome/Chromium ####

Those browsers have an option to define programs associated to a file (MIME) type. It is pretty straightforward to configure and is outside the scope of this document.

An alternative is to use Raffaele Florio's [qubes-url-redirector](https://github.com/raffaeleflorio/qubes-url-redirector) add-on, which provides a lot of flexibility when opening links without the hassle of having to write custom shell wrappers to `qvm-open-in-vm`. For instance links can be opened with a context menu and the add-on's default behavior can be configured, even with whitelist regexes.

Note: the qubes-url-redirector add-on will likely be included officialy in the next Qubes release (see [this](https://github.com/QubesOS/qubes-issues/issues/3152) issue). The addon may also support Thunderbird in the future.


#### Vi ####

Opening URLs: put the following in `$HOME/.vimrc`:

~~~
let g:netrw_browsex_viewer = 'qvm-open-in-vm dstVM'
~~~

Typing `gx` when the cursor is over an URL will then open it in `dstVM`.


### Application independent setup ###

Configuring *each* application provides a good amount of flexibility but it may not be the best approach when one wants to use the same action/program in *all* the applications in `srcVM`. In that case, provided that the applications adhere to the [freedesktop](https://en.wikipedia.org/wiki/Freedesktop.org) standard, defining a global action for a given URL/file (MIME) type is straightforward:

- put the following in `~/.local/share/applications/browser_vm.desktop`

	~~~
	[Desktop Entry]
	Encoding=UTF-8
	Name=BrowserVM
	Exec=qvm-open-in-vm dstVM %u
	Terminal=false
	X-MultipleArgs=false
	Type=Application
	Categories=Network;WebBrowser;
	MimeType=x-scheme-handler/unknown;x-scheme-handler/about;text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
	~~~

- set xdg's "default browser" to the .desktop entry you've just created with `xdg-settings set default-web-browser browser_vm.desktop`

The same can be done with any Mime type (see `man xdg-mime` and `xdg-settings`).

Again, `qvm-open-in-vm dstVM` can be replaced by a user written wrapper with custom logic for selecting a specific dstVM depending on the URL/file type, site level of trust, ...

**Caveat**: if dom0 default permissions are set to allow without user confirmation applications can leak data through URLs despite `srcVM`'s restrictive firewall (you may notice that an URL has been open in `dstVM` but it would be too late).


"Semi-permanent" named dispVMs
------------------------------

Opening things in dispVMs is the most secure approach, but the long starting time of dispVMs often gets in the way so users end up opening files/URLs in persistent VMs. An intermediate solution is to create a "semi-permanent" dispVM like so (replace `fedora-28-dvm` with the dvm template you want to use):

~~~
qvm-create -C DispVM -t fedora-28-dvm -l red dstVM
~~~

This VM works like a regular VM, with the difference that its private disk is wiped after it's powered off. However it doesn't "auto power off" like random dispVMs so it's up to the user to power off (and optionaly restart) the VM when he/she deems necessary.


Further considerations/caveats of using dispVMs
-----------------------------------------------

Obviously, using dispVMs as `dstVM` means that changes are lost when `dstVM` is powered off so the increased security of this setup makes saving deliberate changes harder.

- inter-VM copy/paste is probably the easiest way to synchronize text between `dstVM` and `srcVM` (or another dedicated secure VM like the oft-used 'vault' VM). Eg.:
   - passwords: copy/paste from/to KeepassX (or one of its forks).
   - bookmarks: copy/paste from/to a plain text file, or an html file (like most browsers can export/import), or a dedicated bookmark manager like [buku](https://github.com/jarun/Buku) (command line manager, available in Fedora 28 repo - `dnf install buku`).
- other content/changes will have to be copied, usually to `dstVM`'s templateVM. Care must be taken not to replicate compromised files: working with a freshly started `dstVM` and performing only the required update actions before synchronizing files with the templateVM is usually a good idea.

---

`Contributors`: @Aekez, @taradiddles

`Credits:` @raffaeleflorio, [Micah Lee](https://micahflee.com/2016/06/qubes-tip-opening-links-in-your-preferred-appvm/)
