Mirage Firewall
===============

A unikernel firewall for Qubes OS.
This site will help collecting information about the mirage firewall, an interesting project from "talex5".

To learn more about the Mirage Firewall, please make sure to read

- https://github.com/mirage/qubes-mirage-firewall
- https://github.com/mirage/qubes-mirage-firewall/blob/master/README.md

The Mirage Firewall for Qubes OS is a low ressource firewall, which uses a much smaller footprint
compared to the default ("fat") sys-firewall.

This page is only to write down how to build the mirage firewall for Qubes OS.
Please make sure to read the above links to understand more about it.

Build process on Qubes 4
========================
```
# create a new template VM
qvm-clone fedora-29-minimal t-fedora-29-mirage

# Resize private disk to 10 GB
qvm-volume extend t-fedora-29-mirage:private 10GB

# Create a symbolic link to safe docker into the home directory
qvm-run --auto --user root --pass-io --no-gui \
  'ln -s /var/lib/docker /home/user/docker'

# Install docker and git
qvm-run --user root --pass-io --no-gui \
  'dnf -y install docker git'

# To get networking in the template VM
qvm-run --auto --user root --pass-io --no-gui \
  'dnf install qubes-core-agent-networking'
qvm-shutdown --wait t-fedora-29-mirage
qvm-prefs t-fedora-29-mirage sys-firewall
qvm-start t-fedora-29-mirage

# Launch docker
qvm-run --user root --pass-io --no-gui \
  'systemctl start docker'

# Download and build mirage for qubes
qvm-run --user root --pass-io --no-gui \
  'cd /home/user && \
   git clone https://github.com/mirage/qubes-mirage-firewall.git && \'
   cd qubes-mirage-firewall && \
   ./build-with-docker.sh'
