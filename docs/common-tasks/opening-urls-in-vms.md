How to open URLs/files in other VMs
===================================

Qubes' philosophy is to assume you are already compromised and to partition your work / data in a way that even if all your VMs are compromised an attacker would not be able to extract any information. This document describes how to implement such compartmentalization when opening URLs and files from "secure" offline or firewalled VMs. Configuration samples throughout this document show how to setup a flexible and powerful workflow, mitigating the long starting time and resource usage of dispVMs that unfortunately often results in users not taking advantage of them.

Naming convention:

- `srcVM` is the VM where the files/URLs are
- `dstVM` is the VM we want to open them in ; `dstVM` can be any VM type - a DispVM, a regular AppVM, a Whonix workstation dvm, ...


Configuring dom0 RPC permissions
--------------------------------

Opening files and URLs in other VMs rely on the `qubes.OpenInVM` and `qubes.OpenURL` [RPC services](https://www.qubes-os.org/doc/qrexec3/#qubes-rpc-services), which are called by `srcVM`'s `qvm-open-in-vm` and `qvm-open-in-dvm` shell scripts.

Qubes [RPC policies](https://www.qubes-os.org/doc/rpc-policy/) allow to fine tune how those RPC services can be used between VMs.

### The (powerful) `ask` policy ###

A very powerful and convenient RPC policy rule is `ask`: in that case a dialog with the list of destination VMs pops up each time the RPC service is called, allowing the user to select a destination VM depending on his work's context (eg. the target URL's level of trust, protocol, file [MIME](https://en.wikipedia.org/wiki/Media_type) type, ...).

It is impossible to overstate how flexible this is and how much security it can add to one's workflow: while opening things in dispVMs is the most secure approach the problem is starting a dispVM for *each* URL/file takes far too much time and resources, leading people to open files/URLs in persistent VMs instead.

The `ask` policy's VM selection dialog allows one to start any type of VM or dispVM (see section "Considerations on dispVMs" below), or send the URL/file to an already running (disp)VM. The first time an URL/file is opened the (disp)VM will start if it wasn't running. The next time another URL/file is sent, there's no need start a new (disp)VM, one can instead select the already running (disp)VM. It is also possible to choose 'cancel' in the dialog and nothing will launch.

This setup makes it possible to control if and on which network (eg. "clearnet", TOR, VPN) an URL is requested - always. It also effectively mitigates the long starting times of dispVMs.

Note: when using the `ask` policy, the destination VM specified in `srcVM` by `qvm-open-in-vm` is ignored if no `allow` match exists for that given `srcVM`/`dstVM` combo.


### The `allow` policy ###

If an `allow` policy is configured with a destination other than `$dispvm` it is obviously up to `srcVM` to provide the name of the destination VM. The RPC policies should then be configured accordingly.

**Caveat**: even with offline `srcVM`s, `allow` policies allow applications in `srcVM` to leak data through URLs. You might notice that an URL has been open in the destination VM but it would be too late.


### Sample policy ###

In the following example, opening URLs in specific VMs is explicitely forbidden to prevent mistakenly selecting such VM, opening URLs in regular dispVMs is always allowed, and the default policy is to have the selection dialog pop up for everything else.

`/etc/qubes-rpc/qubes.OpenURL`:

~~~
@anyvm vault deny
@anyvm private deny
@anyvm banking deny
@anyvm @dispvm allow
@anyvm @anyvm ask
~~~

`/etc/qubes-rpc/qubes.OpenInVM`:

~~~
@anyvm @anyvm ask
~~~

You may also restrict the type of dispVM allowed in the policy by using the `@dispvm:templatename` syntax. See the [official doc](https://www.qubes-os.org/doc/disposablevm/#opening-a-link-in-a-disposablevm-based-on-a-non-default-disposablevm-template-from-a-qube) for further details.


Considerations on dispVMs
-------------------------

### Re-using dispVMs ###

In the section above we've seen how using the 'ask' RPC policy allowed us to start a (disp)VM once and use it for opening subsequent URLs (or files) to avoid having to wait insane amounts of time for dispVMs to start. Howecer this comes at the price of a loss in compartmentalization. It is thus up to the user to carefully pick destination VMs and to manage the lifecycle of dispVMs, killing it/them when necessary when a clean state is required.

### Managing changes ###

When opening and modifying a document in a dispVM the content is sent back to `srcVM` when the dispVM's process (eg. LibreOffice) closes. The dispVM's private volume is then wiped and any change that was made to the VM are discarded - eg. automatically updated add-ons, blacklists, tweaked browser preferences, ... ; The following ideas show how to cope with those "deliberate" changes:

- inter-VM copy/paste is probably the easiest way to synchronize small amounts of data in text form from the dispVM to `srcVM` (or to another dedicated VM like the oft-used 'vault' VM). Eg.:
   - passwords: copy/paste from/to KeepassX (or one of its forks).
   - bookmarks: copy/paste from/to
      - a plain text file
      - or an html bookmark file (most browsers can export/import such file)
      - or a dedicated bookmark manager like [buku](https://github.com/jarun/Buku) (command line manager, available in Fedora 28 repo - `dnf install buku`).
- other content/changes will have to be copied, usually to the dispVM templateVM. Care must be taken not to replicate compromised files: working with a freshly started dispVM and performing only the required update actions before synchronizing files with the templateVM is a good idea.

### Using "named" dispVMs ###

As of Qubes R4.0, it is impossible to "name" a dispVM: opening a URL/file in a standard dispVMs will always start a VM with a 'dispXXXX' name (eg. 'disp1234').

If for some reason a user needs to have use a dispVM with a given name - which is for instance handy when using `allow` RPC policies - he/she can do like so (replace `fedora-28-dvm` with the dvm template you want to use):

~~~
qvm-create -C DispVM -t fedora-28-dvm -l red dstVM
~~~

This VM works like a regular VM, with the difference that its private disk is wiped after it's powered off. However it doesn't "auto power off" like random dispVMs so it's up to the user to power off (and optionaly restart) the VM when he/she deems necessary.

### Sample real-world workflow ###

Here's an example of a real-world, thoroughly used setup/workflow:

Disposable VMs are based on the following templates:

- dvm-offline (many apps, libreoffice, VLC etc. -- no network)
- dvm-online (minimal with firefox only)
- dvm-anon (whonix workstation)

AppVMs are highly specialized: vault (offline), documents (offline), media (offline), email (firewalled). Those is where information lives. But files do not get opened nor worked on there ... only on instances of dvm-offline.


Configuring `srcVM`
-------------------

The subsections below list various approaches on opening URLs/files from `srcVM` in destination VMs. A hassle-free but very powerful setup is to use the application-independent approach documented in the next subsection with the `ask` RPC policy.


### Application-independent setup ###

It is possible to (re)define a *default* handler for programs/URLs so that this handler is automatically called by *all* the applications in `srcVM` - provided that the applications adhere to the [freedesktop](https://en.wikipedia.org/wiki/Freedesktop.org) standard which is most always the case nowadays.

Defining a new handler simply requires creating a [.desktop](https://specifications.freedesktop.org/desktop-entry-spec/latest/) file and registering it. The following example shows how to open http/https URLs (along with some other common "web" Mime types) with `qvm-open-in-vm`:

- create `$HOME/.local/share/applications/browser_vm.desktop` with the following text:

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

- register the .desktop file you've just created with `xdg-settings set default-web-browser browser_vm.desktop`. 

The same can be done with any Mime type (see `man xdg-mime` and `xdg-settings`); you could either reuse the .desktop created above and add Mime types to the `MimeType=` line, or create and register another .desktop file.

Notes:

- for some reasons some applications may not honor the new xdg application/handler (eg. if you had previously configured default applications), in which case you'd have to manually select the xdg application (see section below).
- `qvm-open-in-vm dstVM` can be replaced by a user written wrapper with custom logic for selecting a specific `dstVM` depending on the URL/file type, site level of trust, ... ; The RPC policies should be configured accordingly.
- very security conscious users should consider basing AppVMs on minimal templates; that way, unless the default handler is set, nothing else is usually there to open those files (little risk, plus the VMs are firewalled or offline).


### Application-specific setup ###

Most applications provide a way to select a given program to use for opening specific URL/file (MIME) types. We can use that feature to select the `/usr/bin/qvm-open-in-{vm,dvm}` scripts instead of the default programs.

The subsections below show how to configure popular applications.


#### Firefox, Chrome/Chromium ####

Those browsers have an option to define programs associated to a file (MIME) type. It is pretty straightforward to configure and is outside the scope of this document.

An alternative is to use Raffaele Florio's [qubes-url-redirector](https://github.com/raffaeleflorio/qubes-url-redirector) add-on, which provides a lot of flexibility when opening links without the hassle of having to write custom shell wrappers to `qvm-open-in-vm`. For instance links can be opened with a context menu and the add-on's default behavior can be configured, even with whitelist regexes.

Notes:
- the qubes-url-redirector add-on will likely be included officialy in Qubes (see [this](https://github.com/QubesOS/qubes-issues/issues/3152) issue).
- the add-on can actually be used with applications other than firefox/chrome/chromium, the only requirement is that URLs open in a browser in `srcVM`. It works like so:
   - the application in `srcVM` opens an URL in the default browser in `srcVM` (eg. firefox)
   - firefox starts on `srcVM`, the add-on processes the URL and according to its configuration "sends" the URL to the destination VM with `qubes.OpenURL`
   - the URL opens in the destination VM's browser


#### Thunderbird ####

**Opening attachements**: "actions" must be defined, see section "Download Actions" settings" in [this document](http://kb.mozillazine.org/Actions_for_attachment_file_types).

**Opening URLs**: changing the way http and https URLs are opened requires tweaking configuration options; see [this](http://kb.mozillazine.org/Changing_the_web_browser_invoked_by_Thunderbird) and [this](http://kb.mozillazine.org/Network.protocol-handler.expose-all) document for more information. Those changes can be made in Thunderbird's built-in config editor, or by adding the following lines to `$HOME/.thunderbird/user.js`:

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

#### Vi ####

Opening URLs: put the following in `$HOME/.vimrc`:

~~~
let g:netrw_browsex_viewer = 'qvm-open-in-vm dstVM'
~~~

Typing `gx` when the cursor is over an URL will then open it in `dstVM` (or will trigger a dialog if `ask` policy is configured, ignoring the `dstVM` argument).


### Inter-VM copy/paste and file copy ###

This approach is obvious and is the simplest one:

- URLs: [copy/paste](https://www.qubes-os.org/doc/copy-paste/) the link in `dstVM`.
- Files: [copy](https://www.qubes-os.org/doc/copying-files/) the file to `dstVM` (provided that `qubes.Filecopy` RPC service's policy allows it - it does by default), and open it from there.


---

`Contributors`: @SvenSemmler, @Aekez, @taradiddles

`Credits:` @raffaeleflorio, [Micah Lee](https://micahflee.com/2016/06/qubes-tip-opening-links-in-your-preferred-appvm/)

