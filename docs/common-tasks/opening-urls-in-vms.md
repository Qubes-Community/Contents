*Note: there is an ongoing [pull request](https://github.com/QubesOS/qubes-doc/pull/1314) to add most of the content of this document to the official Qubes OS documentation.*

<!-- BEGIN PR content -->

This page is about opening URLs and files from one qube in a different qube. The most straightforward way to do this is simply to [copy and paste URLs](/doc/how-to-copy-and-paste-text/) or [copy and move files](/doc/how-to-copy-and-move-files/) from the source qube to the target qube, then manually open them in the target qube. However, some users might wish to use [RPC policies](/doc/rpc-policy/) in order to regiment their workflows and safeguard themselves from making mistakes.

Naming conventions:

- `<SOURCE_QUBE>` is the qube in which the URL or file originates.
- `<TARGET_QUBE>` is the qube in which we wish to open the URL or file.

## Configuring RPC policies

The `qvm-open-in-vm` and `qvm-open-in-dvm` scripts are invoked in a qube to open files and URLs in another qube. Those scripts make use of the `qubes.OpenInVM` and `qubes.OpenURL` [RPC services](/doc/qrexec/#qubes-rpc-services). Qubes [RPC policies](/doc/rpc-policy/) control which RPC services are allowed between qubes.

Policy files are in `/etc/qubes/policy.d/`.

### Using the `ask` action

This action displays a confirmation prompt in dom0 with a drop-down list of allowed target qubes each time the associated RPC service is called. This setup makes it possible to always control whether and in which qube a URL or file opened.

The selected qube will automatically start if it wasn't running. 

**Note:** When using `ask`, the target qube given as an argument to `qvm-open-in-vm` is ignored if no `allow` rule matches the current RPC service and source/target qubes.

### Using the `allow` action

This action allows a specified RPC service to be invoked between source and target qubes without displaying a confirmation prompt in dom0.

When an `allow` action is defined for a target other than `@dispvm`, the target qube is the one given as an argument to `qvm-open-in-vm` in `<SOURCE_QUBE>`. The corresponding RPC policies must be configured accordingly.

**Warning:** Since there is no user confirmation with `allow`, applications in `<SOURCE_QUBE>` could leak data through URLs or file names.

### Using disposables and the `@dispvm` keyword in policies

It is possible to further restrict a target disposable qube by specifying the template on which it is based with the `@dispvm:<DISPOSABLE_TEMPLATE>` syntax ([learn more](/doc/how-to-use-disposables/#opening-a-link-in-a-disposable-based-on-a-non-default-disposable-template-from-a-qube)).

**Note:** The keyword `@dispvm` designates any disposable based on the calling qube's default disposable template. It does *not* designate any disposable whatsoever. For example, if you were to run `qvm-open-in-vm @dispvm:<ONLINE_DISPOSABLE_TEMPLATE> https://www.qubes-os.org` in `<SOURCE_QUBE>` while `<ONLINE_DISPOSABLE_TEMPLATE>` is *not* `<SOURCE_QUBE>`'s default disposable template, it wouldn't work if your policy line merely had `@dispvm` as the target. You would have to use `@dispvm:<ONLINE_DISPOSABLE_TEMPLATE>` as the target instead.

## Sample RPC user policy

_See the main document, [RPC policies](/doc/rpc-policy/), for more information._

The following is a partial example of the kinds of `qubes.OpenInVM` and `qubes.OpenURL` rules that you could write in `/etc/qubes/policy.d/30-user.policy`:

~~~
# Deny opening files or URLs from or in 'vault'
qubes.OpenInVM   *   @anyvm   vault         deny
qubes.OpenURL    *   @anyvm   vault         deny
qubes.OpenInVM   *   vault    @anyvm        deny
qubes.OpenURL    *   vault    @anyvm        deny

# Allow 'work' to open URLs in disposable qubes without prompting the user
qubes.OpenURL    *   work     @dispvm       allow

# Allow 'work' to open files in 'untrusted' without prompting the user
qubes.OpenInVM   *   work     @dispvm       allow target=untrusted

# Allow any qube to open files and URLs in disposables based on the
# disposable templates 'foo' and 'bar'
qubes.OpenInVM   *   @anyvm   @dispvm:foo   allow
qubes.OpenURL    *   @anyvm   @dispvm:bar   allow

# Prompt the user before opening any file or URL in any other qube, but prefill
# the target with 'personal' for files and 'untrusted' for URLs
qubes.OpenInVM   *   @anyvm   @anyvm        ask default_target=personal
qubes.OpenURL    *   @anyvm   @anyvm        ask default_target=untrusted
~~~

## Configuring application handlers

It is possible to (re)define a default application handler so that it is automatically called by *any* application in `<SOURCE_QUBE>` to open files or URLs provided that the applications adhere to the [freedesktop](https://en.wikipedia.org/wiki/Freedesktop.org) standard (which is almost always the case nowadays).

For application-specific configurations or applications that don't adhere to the freedesktop standard, please refer to the unofficial, external [community documentation](https://github.com/Qubes-Community/Contents/blob/master/docs/common-tasks/opening-urls-in-vms.md).

Defining a new handler simply requires creating a [.desktop](https://specifications.freedesktop.org/desktop-entry-spec/latest/) file and registering it. The following example shows how to open http/https URLs (along with common "web" [media types](https://en.wikipedia.org/wiki/Media_type)) with `qvm-open-in-vm`:

- Create `$HOME/.local/share/applications/mybrowser.desktop` with the following content:

	~~~
	[Desktop Entry]
	Encoding=UTF-8
	Name=MyBrowser
	Exec=qvm-open-in-vm <TARGET_QUBE> %u
	Terminal=false
	X-MultipleArgs=false
	Type=Application
	Categories=Network;WebBrowser;
	MimeType=x-scheme-handler/unknown;x-scheme-handler/about;text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
	~~~

- Register the `.desktop` file with `xdg-settings set default-web-browser mybrowser.desktop`. 

The same can be done with any other media type (see `man xdg-mime` and `xdg-settings`).

### Notes

- Some applications may not use the new XDG application handler (e.g., if you had previously configured default applications), in which case you'd have to manually configure the application to use the XDG handler.

- `qvm-open-in-vm target-qube %u` can be replaced by a user wrapper with custom logic for selecting different target qubes depending on the URL/file type, level of trust, etc. The RPC policies should be configured accordingly.

- Advanced users may wish to consider basing app qubes on [minimal templates](/doc/templates/minimal/). That way, unless a default handler is set, it is unlikely that any other program will be present that can open the URL or file.

<!-- END PR content -->

## Configuring specific applications

Most applications provide a way to select a given program to use for opening specific URL/file (MIME) types. We can use that feature to select the `/usr/bin/qvm-open-in-{vm,dvm}` scripts instead of the default programs.

The subsections below show how to configure popular applications in case the "default handler" approach above doesn't work / isn't sufficient.

### Firefox, Chrome/Chromium

Those browsers have an option to define programs associated to a file (MIME) type. It is pretty straightforward to configure and is outside the scope of this document.

An alternative is to use Raffaele Florio's [qubes-url-redirector](https://github.com/raffaeleflorio/qubes-url-redirector) add-on, which provides a lot of flexibility when opening links without the hassle of having to write custom shell wrappers to `qvm-open-in-vm`. For instance links can be opened with a context menu and the add-on's default behavior can be configured, even with whitelist regexes.

Notes:

- the qubes-url-redirector add-on will likely be included officialy in Qubes (see [this](https://github.com/QubesOS/qubes-issues/issues/3152) issue).
- the add-on can actually be used with applications other than firefox/chrome/chromium, the only requirement is that URLs open in a browser in `<SOURCE_QUBE>`. It works like so:
  - the application in `<SOURCE_QUBE>` opens an URL in the default browser in `<SOURCE_QUBE>` (eg. firefox)
  - firefox starts on `<SOURCE_QUBE>`, the add-on processes the URL and according to its configuration "sends" the URL to `<TARGET_QUBE>` with `qubes.OpenURL`
  - the URL opens in the `<TARGET_QUBE>`'s browser

### Thunderbird

**Opening attachments**: "actions" must be defined, see section "Download Actions" settings" in [this document](http://kb.mozillazine.org/Actions_for_attachment_file_types).

**Opening URLs**: changing the way http and https URLs are opened requires tweaking configuration options; see [this](http://kb.mozillazine.org/Changing_the_web_browser_invoked_by_Thunderbird) and [this](http://kb.mozillazine.org/Network.protocol-handler.expose-all) document for more information. Those changes can be made in Thunderbird's built-in config editor, or by adding the following lines to `$HOME/.thunderbird/user.js`:

```
user_pref("network.protocol-handler.warn-external.http", true);
user_pref("network.protocol-handler.warn-external.https", true);
user_pref("network.protocol-handler.expose-all", true);
```

Thunderbird will then ask which program to use the next time a link is opened. If `<TARGET_QUBE>` is a standard (random) dispVM, choose `/usr/bin/qvm-open-in-dvm`. Otherwise you'll have to create a wrapper to `qvm-open-in-vm` since arguments cannot be passed to programs selected in Thunderbird's dialog gui. For instance, put the following text in `$HOME/bin/thunderbird-open-url`, make it executable, and select that program when asked which program to use:

```
#!/bin/sh
qvm-open-in-vm <TARGET_QUBE> "$@"
```

### Vi

Opening URLs: put the following in `$HOME/.vimrc`:

```
let g:netrw_browsex_viewer = 'qvm-open-in-vm <TARGET_QUBE>'
```

Typing `gx` when the cursor is over an URL will then open it in `<TARGET_QUBE>` (or will trigger a dialog if `ask` policy is configured, ignoring the `<TARGET_QUBE>` argument).


# Considerations on dispVMs

## Re-using dispVMs

In the section above we've seen how using the 'ask' RPC policy allowed us to start a (disp)VM once and use it for opening subsequent URLs (or files) to avoid having to wait insane amounts of time for dispVMs to start. However this comes at the price of a loss in compartmentalization. It is thus up to the user to carefully pick destination VMs and to manage the lifecycle of dispVMs, killing it/them when necessary when a clean state is required.

## Managing changes

When opening and modifying a document in a dispVM the content is sent back to `<SOURCE_QUBE>` when the dispVM's process (eg. LibreOffice) closes. The dispVM's private volume is then wiped and any change that was made to the VM are discarded - eg. automatically updated add-ons, blacklists, tweaked browser preferences, ... ; The following ideas show how to cope with those "deliberate" changes:

- inter-VM copy/paste is probably the easiest way to synchronize small amounts of data in text form from the dispVM to `<SOURCE_QUBE>` (or to another dedicated VM like the oft-used 'vault' VM). Eg.:
  - passwords: copy/paste from/to KeepassX (or one of its forks).
  - bookmarks: copy/paste from/to
    - a plain text file
    - or an html bookmark file (most browsers can export/import such file)
    - or a dedicated bookmark manager like [buku](https://github.com/jarun/Buku) (command line manager, available in Fedora 28 repo - `dnf install buku`).
- other content/changes will have to be copied, usually to the dispVM templateVM. Care must be taken not to replicate compromised files: working with a freshly started dispVM and performing only the required update actions before synchronizing files with the templateVM is a good idea.

## Using "named" dispVMs

If for some reason a user needs to have use a dispVM with a given name - which is for instance handy when using `allow` RPC policies - he/she can do like so (replace `fedora-28-dvm` with the dvm template you want to use):

```
qvm-create -C DispVM -t fedora-28-dvm -l red <TARGET_QUBE>
```

This VM works like a regular VM, with the difference that its private disk is wiped after it's powered off. However it doesn't "auto power off" like random dispVMs so it's up to the user to power off (and optionally restart) the VM when he/she deems necessary.


------------------------------------------------------------------------

`Credits:` @raffaeleflorio, [Micah Lee](https://micahflee.com/2016/06/qubes-tip-opening-links-in-your-preferred-appvm/)
