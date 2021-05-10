
How to Make a Multimedia TemplateVM
===================================

Note: This Howto has been written and was tested under Qubes 4rc4

You can consolidate most of your media streaming tasks into one "multimedia" App-VM. This howto explains how to create a multimedia template which can be used to play multimedia content.
This includes:

- Spotify
- Amazon Prime
- Netflix
- DVDs

Installation
------------

Start by cloning the default debian template in dom0.
Hint:
t-multimedia is just the template VM where we will install all packages.
In the last step we will create an AppVM from this template.

`qvm-clone debian-10 t-multimedia`

Launch a Terminal in the new template VM:

`qvm-run --auto t-multimedia gnome-terminal`

Important:
Enter all the following commands in the terminal of the template VM.
Become the root user to run all following command without the need to use sudo in the multimedia template VM.

`sudo -i`

This howto assumes that you have xclip available in the AppVM where you download the Repository Signing keys.
xclip will be used to paste the content of the clipboard to a file.
You can install xclip via:

`apt-get install xclip` on Debian
`dnf install xclip` on Fedora

You can of course install xclip just into the AppVM where you download the signing keys to have it available for this howto and it will be deleted if you reboot the AppVM. To have xclip available also after a reboot you need to install it in the Template VM on which your Internet AppVM is based (make sure to reboot the AppVM after you've installed any package in its template)  

Installation of Spotify
-----------------------

Import GPG-Key for spotify
As the template VM can't connect to internet you need to get the public key file from another AppVM and copy it to the template VM. The easiest way is to use the Qubes Clipboard to copy the keys from the AppVM where you get the key to the Template VM.

In an AppVM which has Internet access:
- Open <https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x8fd3d9a8d3800305a9fff259d1742ad60d811d58>
- Copy content of page to the Clipboard (Ctrl+A and Ctrl+C)
- open a Terminal in this AppVM and copy the content of the clipboard to a file
  `xclip -o > spotify.pubkey`

Copy the public signing key over to the multimedia template VM
- copy the file via `qvm-copy-to-vm t-multimedia spotify.pubkey`
- or create a new file on the Template VM and copy the content of the clipboard (the public key)
  Copy content of page to the Qubes Clipboard (Ctrl+C and then Shift+Ctrl+C)
  Switch to the gnome terminal in the Multimedia Template VM
  `nano spotify.pubkey`
  Paste the content from the Qubes Clipboard into nano (Shift+Ctrl+V and then Paste)
  Save the file (Ctrl+O <Enter> Ctrl+X)

Check the signature of the signing key (in the multimedia Template VM).
Hint: depending on your installed version of GnuPG the command to show a public might slightly be different.
See [this StackExchange question](https://unix.stackexchange.com/questions/391344/gnupg-command-to-show-key-info-from-file) for more information.
If this command doesn't show a fingerprint choose one of the other commands mentioned in the above link.

`gpg --keyid-format long --with-fingerprint spotify.pubkey`

This should look like:
 
    [user@t-multimedia ~]$ gpg --keyid-format long --with-fingerprint spotify.pubkey 
    
    gpg: WARNING: no command supplied.  Trying to guess what you mean ...
    pub   rsa4096/D1742AD60D811D58 2020-09-08 [SC] [expires: 2021-12-02]
      Key fingerprint = 8FD3 D9A8 D380 0305 A9FF  F259 D174 2AD6 0D81 1D58
    uid                           Spotify Public Repository Signing Key <tux@spotify.com>
         

You can (and should) lookup the fingerprint on at least one (or more) keyservers as the above information might be outdated.

<https://keyserver.ubuntu.com/pks/lookup?op=vindex&search=0x4773BD5E130D1D45&fingerprint=on>

Add the public key to the repository keyring
`apt-key add spotify.pubkey`

Add the Spotify repository to your list of package sources:

`echo deb http://repository.spotify.com stable non-free > /etc/apt/sources.list.d/spotify.list`

Update the list of all known packages

`apt-get update`

Install Spotify
`apt-get install -y spotify-client`

Create a spotify desktop-entry

`cp -p /usr/share/spotify/spotify.desktop /usr/share/applications/`

`cp /usr/share/spotify/icons/spotify-linux-16.png /usr/share/icons/hicolor/16x16/apps/spotify.png`


Installation of VLC
-------------------

To play DVDs you can install VLC with the needed Codecs

Download the public key which signs the VLC package repositories
In an AppVM which has Internet access:
- Open <https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x6BCA5E4DB84288D9>
- Repeat all steps to save the public signing key on the AppVM (see above / Spotify example)
  `xclip -o > videolan.pubkey`
  
Copy the public signing key over to the multimedia template VM
- copy the file via `qvm-copy-to-vm t-multimedia videolan.pubkey`
- or create a new file on the Template VM and copy the content of the clipboard (the public key)
  Copy content of page to the Qubes Clipboard (Ctrl+C and then Shift+Ctrl+C)
  Switch to the gnome terminal in the Multimedia Template VM
  `nano videolan.pubkey`
  Paste the content from the Qubes Clipboard into nano (Shift+Ctrl+V and then Paste)
  Save the file (Ctrl+O <Enter> Ctrl+X)

Check the signature of the signing key

`gpg --keyid-format long --with-fingerprint videolan.pubkey`

This should look like:

    [user@t-multimedia ~]$ gpg --keyid-format long --with-fingerprint videolan.pubkey
    
    gpg: WARNING: no command supplied.  Trying to guess what you mean ...
    pub   rsa2048/6BCA5E4DB84288D9 2013-08-27 [SC]
          Key fingerprint = 8F08 45FE 77B1 6294 429A  7934 6BCA 5E4D B842 88D9
    uid                           VideoLAN APT Signing Key <videolan@videolan.org>
    sub   rsa2048/ED1466D0288D4A2C 2013-08-27 [E]

You can (and should) lookup the fingerprint on at least one (or more) keyservers as the above information might be outdated.

<https://keyserver.ubuntu.com/pks/lookup?op=vindex&search=0x6BCA5E4DB84288D9&fingerprint=on>

Add the public key to the repository keyring
`apt-key add videolan.pubkey`

Add the new VLC package repositories to your list of sources 

`echo "deb http://download.videolan.org/pub/debian/stable/ /" > /etc/apt/sources.list.d/vlc.list`

`echo "deb-src http://download.videolan.org/pub/debian/stable/ /" >> /etc/apt/sources.list.d/vlc.list`

Update package repositories

`apt-get update`

Install libdvdcss and VLC

`apt-get install -y libdvdcss2 vlc`


Installation Google Chrome
--------------------------

To play Videos with Netflix, Amazon Prime & Co using Chrome is a good option as it has all needed codecs included.
Hint: Using Chromium will not work for some reasons.

Download the public key which signs the Google package repositories
In an AppVM which has Internet access:
- Open <https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x7721F63BD38B4796>
- Repeat all steps to save the public signing key on the AppVM (see above / Spotify example)
  `xclip -o > google.pubkey`

Copy the public signing key over to the multimedia template VM
- copy the file via `qvm-copy-to-vm t-multimedia google.pubkey`
- or create a new file on the Template VM and copy the content of the clipboard (the public key)
  Copy content of page to the Qubes Clipboard (Ctrl+C and then Shift+Ctrl+C)
  Switch to the gnome terminal in the Multimedia Template VM
  `nano google.pubkey`
  Paste the content from the Qubes Clipboard into nano (Shift+Ctrl+V and then Paste)
  Save the file (Ctrl+O <Enter> Ctrl+X)

Check the signature of the signing key (still in the AppVM where you downloaded the key)

`gpg --keyid-format long --with-fingerprint google.pubkey`

This should look like:

    [user@t-multimedia ~]$ gpg --keyid-format long --with-fingerprint videolan.pubkey
    
    gpg: WARNING: no command supplied.  Trying to guess what you mean ...
    pub   rsa4096/7721F63BD38B4796 2016-04-12 [SC]
          Key fingerprint = EB4C 1BFD 4F04 2F6D DDCC  EC91 7721 F63B D38B 4796
    uid                           Google Inc. (Linux Packages Signing Authority) <linux-packages-keymaster@google.com>
    sub   rsa4096/1397BC53640DB551 2016-04-12 [S] [expired: 2019-04-12]
    sub   rsa4096/6494C6D6997C215E 2017-01-24 [S] [expired: 2020-01-24]
    sub   rsa4096/78BD65473CB3BD13 2019-07-22 [S] [expires: 2022-07-21]

You can (and should) lookup the fingerprint on at least one (or more) keyservers as the above information might be outdated.

<https://keyserver.ubuntu.com/pks/lookup?op=vindex&search=0x7721F63BD38B4796&fingerprint=on>

or

<https://www.google.com/linuxrepositories/>

Add the public key to the repository keyring

`apt-key add google.pubkey`

Add the Google package repositories to your list of sources 

`echo "deb http://dl.google.com/linux/chrome/deb/ stable main"> /etc/apt/sources.list.d/google.list`

Update package repositories

`apt-get update`

Install Chrome 

`apt-get install google-chrome-stable`


Create a Multimedia AppVM
-------------------------

The last step is to create a multimedia AppVM (named "my-multimedia" here) based on the new multimedia template.

`qvm-create --template t-multimedia --label orange my-multimedia`

