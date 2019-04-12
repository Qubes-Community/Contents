#!/bin/bash

########################################################
# Make a LVM image appear in qvm-block
# Create a disposable VM
# Attach the image to the newly created disposable VM
# Wait until the disposable VM is destroyed
# Remove the LVM image from the qvm-block list
######################################################

image=${1?Image file is required, exemple "/dev/qubes_dom0/vm-debian-9-tmp-root"}
dvm=${2?DVM template name is required, example: "fedora-29-dvm"}
dev=$(basename $(readlink "$image"))
qubesdb-write /qubes-block-devices/$dev/desc "$image"
list_before=$(qvm-ls | cut -d " " -f1 | sort)
qvm-run -v --dispvm=$dvm --service qubes.StartApp+xterm &
sleep 5
list_after=$(qvm-ls | cut -d " " -f1 | sort)
diff=$(comm -3 <(echo "$list_before") <(echo "$list_after"))
qvm-block attach $diff dom0:$dev
wait
qubesdb-rm /qubes-block-devices/$dev/
