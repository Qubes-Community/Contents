#!/bin/bash
# qvm-copy-to-vm2
# Copy a file from dom0 to a specific location in an AppVM
# qvm-copy-to-dom0 <Source in dom0> <AppVM> <Destination in dom0>

# command line parameters
Source="$1"      # must be present
AppVM="$2"       # must be present
Destination="$3" # must be present

# if no Destination given on commandline use /home/user/QubesIncoming
if [ -z "$Destination" ];then Destination="/home/user/QubesIncoming"; fi

# copy file from dom0 to AppVM
qvm-run --pass-io $AppVM "cat -- \"$Source\"" > "$Destination"
