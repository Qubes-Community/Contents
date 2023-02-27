How to Enable Tailscale in AppVM
==================================
<b>Note:</b> If you seek to enhance your privacy, you may also wish to consider a <a href="/doc/configuration/vpn.md">VPN proxy Qube</a>.

<a href="https://tailscale.com/">Tailscale</a> is a mesh private network that lets you easily manage access to private resources, quickly SSH into devices on your network, and work securely from anywhere in the world. If you have devices in your private home network or at work at which you cannot use a VPN, Tailscale is a simple alternative with minimal setup.

### Template VM

In a `t-tailscale` template VM, install tailscale with the simple sh script, then stop the service:

```
-curl -fsSL https://tailscale.com/install.sh | sh
systemctl stop tailscaled
```

### AppVM

In your `tailscale` AppVM, use your favorite editor to sudo edit '/rw/config/rc.local', adding the following lines at the bottom of the file:

```
sudo systemctl start tailscaled
sudo tailscale up
```

Now make sure folder /rw/config/qubes-bind-dirs.d exists.
  
``` 
sudo mkdir -p /rw/config/qubes-bind-dirs.d
```

Create a file /rw/config/qubes-bind-dirs.d/50_user.conf with root rights. Edit the file 50_user.conf to append a folder or file name to the binds variable.

```
binds+=( '/var/lib/tailscale' )
```
Save.

Reboot the app qube.

Done.

From now on any files within the /var/lib/tailscale folder will persist across reboots. Shutdown and reboot the VM. Enter a console and run `sudo tailscale up` again to get the Tailscale tunnel link to your VM.
