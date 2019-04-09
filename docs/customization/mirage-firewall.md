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

Most information from here has been put together reading the original docs above and following the discussion in the Qubes OS User Mailinglist / Google Groups:
https://groups.google.com/forum/#!topic/qubes-users/xfnVdd1Plvk


Build process on Qubes 4
========================
```
MirageFW-BuildVM=my-mirage-buildvm
TemplateVM=fedora-29
MirageFWAppVM=sys-mirage-fw

# create a new VM to build mirage via docker
qvm-create $MirageFW-BuildVM --class=AppVM --label=red --template=$TemplateVM

# Resize private disk to 10 GB
qvm-volume resize $MirageFW-BuildVM:private 10GB

# Create a symbolic link to safe docker into the home directory
qvm-run --auto --pass-io --no-gui $MirageFW-BuildVM \
  'sudo mkdir /home/user/var_lib_docker && \  
   sudo ln -s /var/lib/docker /home/user/var_lib_docker'

# Install docker and git
qvm-run --pass-io --no-gui $MirageFW-BuildVM \
  'sudo dnf -y install docker git'

# Launch docker
qvm-run --pass-io --no-gui $MirageFW-BuildVM \
  'sudo systemctl start docker'

# Download and build mirage for qubes
qvm-run --pass-io --no-gui $MirageFW-BuildVM \
  'git clone https://github.com/mirage/qubes-mirage-firewall.git && \
   cd qubes-mirage-firewall && \
   git pull origin pull/52/head && \
   sudo ./build-with-docker.sh'

# Copy the new kernel to dom0
cd /var/lib/qubes/vm-kernels
qvm-run --pass-io $MirageFW-BuildVM 'cat qubes-mirage-firewall/mirage-firewall.tar.bz2' | tar xjf -

# create the new mirage firewall
qvm-create \
  --property kernel=mirage-firewall \
  --property kernelopts=None \
  --property memory=32 \
  --property maxmem=32 \
  --property netvm=sys-net \
  --property provides_network=True \
  --property vcpus=1 \
  --property virt_mode=pv \
  --label=green \
  --class StandaloneVM \
  $MirageFWAppVM
```

For rebuilds / Updates
======================
```
# delete old build
qvm-run --pass-io --no-gui $MirageTemplateVM \
  'rm -Rf /home/user/'

# Download and build mirage for qubes
qvm-run --pass-io --no-gui $MirageTemplateVM \
  'git fetch https://github.com/mirage/qubes-mirage-firewall.git && \ 
   cd qubes-mirage-firewall && \
   # git pull origin pull/52/head && \
   sudo ./build-with-docker.sh'

# Copy the new kernel to dom0
cd /var/lib/qubes/vm-kernels
qvm-run --pass-io $MirageFW-BuildVM 'cat qubes-mirage-firewall/mirage-firewall.tar.bz2' | tar xjf -

# Shutdown Mirage-FW
qvm-shutdown --wait $MirageFWAppVM

# Start Mirage-FW
qvm-start $MirageFWAppVM
```
