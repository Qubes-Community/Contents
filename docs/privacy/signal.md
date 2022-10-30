
Signal
======

What is [Signal]?

[According to Wikipedia:][signal-wikipedia]

> Signal is an encrypted instant messaging and voice calling application
> for Android and iOS. It uses end-to-end encryption to secure all
> communications to other Signal users. Signal can be used to send and receive
> encrypted instant messages, group messages, attachments and media messages.
> Users can independently verify the identity of their messaging correspondents
> by comparing key fingerprints out-of-band.
> 
> Signal is developed by Signal Technology Foundation and Signal Messenger LLC.
> The mobile clients for  are published as free and open-source software under
> the GPLv3 license, while the desktop client and server are published under the
> AGPL-3.0-only license.

How to install Signal Desktop in Qubes
--------------------------------------

**CAUTION:** Before proceeding, please carefully read [On Digital Signatures and Key Verification][qubes-verifying-signatures].
This website cannot guarantee that any PGP key you download from the Internet is authentic.
Always obtain a trusted key fingerprint via other channels, and always check any key you download against your trusted copy of the fingerprint.

The following adapts the official [Linux (Debian-based) Install Instructions][signal-debian-instructions] from Signal's website for Qubes.

1. (Optional) Create a TemplateVM (`debian-11` is used as an example, but can be `debian-11-minimal`, `debian-10`, etc.):

       [user@dom0 ~]$ sudo qubesctl --skip-dom0 --targets=debian-11 --show-output state.sls update.qubes-vm

2. Open a terminal in Debian 11 (or your previously chosen template; note that `gnome-terminal` isn't installed by default in a [minimal template], in that case replace `gnome-terminal` with `uxterm`):

       [user@dom0 ~]$ qvm-run -a debian-11 gnome-terminal
       
3. Run the commands below in the terminal you've just opened.

    Install the curl program needed to download the Signal signing key:

       sudo apt install curl

    We need a notification daemon, otherwise Signal will hang the first time you receive a message when the window doesn’t have the focus (alternatively you could install `xfce4-notifyd` instead of `dunst`):
  
       sudo apt install dunst

    Download the Signal signing key (we need to pass the `--proxy` argument to `curl` as TemplateVMs can only access internet through a proxy at localhost/127.0.0.1 port 8082):

       curl --proxy 127.0.0.1:8082 -s https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

    Add the Signal repository (Signal don't offer a `buster/bullseye` repository - they use `xenial`, but this doesn't affect Debian users):
  
       echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee -a /etc/apt/sources.list.d/signal-desktop.list

    Then fetch all repositories (now including the newly added Signal repository), bring the TemplateVM up-to-date, and finally install Signal:

       sudo apt update && sudo apt full-upgrade && sudo apt install --no-install-recommends signal-desktop

4. A bit more work is required in case you used a minimal template for the TemplateVM above:

    `signal-desktop` requires at least `libatk1.0-0`, `libatk-bridge2.0-0`, `libcups2` and `libgtk-3-0` to run. Those dependencies are automatically installed when installing `xfce4-notifyd`, but if you installed `dunst` you'll have to add them:

       sudo apt install libatk1.0-0 libatk-bridge2.0-0 libcups2 libgtk-3-0

    If you haven't done so already, `qubes-core-agent-networking` must be installed for networking to work in qubes based on minimal templates:

       sudo apt install qubes-core-agent-networking

    Then optionally install the following packages for convenience of handling files (`zenity` is needed by the Qubes OS functions in `qubes-core-agent-nautilus` to show the progress dialog when moving/copying files):

       sudo apt install nautilus qubes-core-agent-nautilus zenity

5. Shutdown the TemplateVM (substitute your template name if needed):

       [user@dom0 ~]$ qvm-shutdown debian-11
        
6. Create an AppVM based on this TemplateVM.

7. With your mouse, select the `Q` menu -> `Domain: "AppVM Name"` -> `"AppVM Name": Qube Settings` -> `Applications` (or in Qubes Manager `"AppVM Name"` -> `Settings` -> `Applications`). Select `Signal` from the left `Available` column, move it to the right `Selected` column by clicking the `>` button and then `OK` to apply the changes and close the window.

-----

[qubes-verifying-signatures]: https://www.qubes-os.org/security/verifying-signatures/
[Signal]: https://signal.org/
[signal-debian-instructions]: https://www.signal.org/download/linux/
[signal-wikipedia]: https://en.wikipedia.org/wiki/Signal_(software)
[shortcut]: https://support.whispersystems.org/hc/en-us/articles/216839277-Where-is-Signal-Desktop-on-my-computer-
[shortcut-desktop]: https://www.qubes-os.org/doc/managing-appvm-shortcuts/#tocAnchor-1-1-1
[message]: https://groups.google.com/d/msg/qubes-users/rMMgeR-KLbU/XXOFri26BAAJ
[mailing list]: https://www.qubes-os.org/support/
[minimal template]: https://www.qubes-os.org/doc/templates/minimal/
