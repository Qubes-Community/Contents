# Connect to a VM console

In some cases it's not possible to use a standard graphical terminal emulator to interact with a VM. In this case, "serial console" access is still available using two tools.

## qvm-console-dispvm

Usage: `qvm-console-dispvm VMNAME`

Launches a DispVM connected to the VM's console, using the qubes.ShowInTerminal RPC service. This provides a full-featured console.

At the time of writing this command contains a bug whose fix is waiting on release, therefore it may be necessary to use the following.

## xl console

Usage: `sudo xl console VMNAME`

Uses Xenlight to directly access the VM console from dom0. For [security reasons](https://github.com/QubesOS/qubes-vmm-xen/blob/xen-4.8/patch-tools-xenconsole-replace-ESC-char-on-xenconsole-outp.patch) this console is deliberately limited in what it can display.

Line-by-line text will work fine, but if a Curses-style pseudo-graphical-interface comes up the output will be garbled and you will need a tool like [asciinema](https://asciinema.org/) to untangle it.
