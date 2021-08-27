## Setting up a Trezor cryptocurrency hardware wallet in Qubes

using a Fedora-based sys-usb VM and a Whonix WS-based application VM:

- in dom0:
    `sudo vim /etc/qubes-rpc/policy/trezord-service`
add this line:
        `$anyvm $anyvm allow,user=trezord,target=sys-usb`
replace `sys-usb` with `disp-sys-usb` if you are using a disposable sys-usb

- in the sys-usb VM, or for disp-sys-usb, the VM on which it is based
  (in both cases, assumed to use a fedora-3x template):
	`sudo mkdir /usr/local/etc/qubes-rpc`
	`sudo vim /usr/local/etc/qubes-rpc/trezord-service`
	and add this line to trezord-service:
	`socat - TCP:localhost:21325`
- in the whonix-based application VM:
    `pip3 install --user trezor`
    `sudo vim /rw/config/rc.local`
	add this line (note the "&" at the end):
    `socat TCP-LISTEN:21325,fork EXEC:"qrexec-client-vm sys-usb trezord-service" &`

- in the fedora-3x template:
    `sudo dnf install trezor-common`

- download the bridge RPM from
    https://wallet.trezor.io/#/bridge
	and remember to verify it!
- copy to fedora-3x
- in fedora-3x
    `sudo rpm -i /path/to/trezor.rpm`
