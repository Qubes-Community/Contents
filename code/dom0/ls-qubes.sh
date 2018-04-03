#!/bin/bash
# ls-qubes.sh
# List Qubes and total RAM used by all Qubes
# Usage: ls-qubes.sh
# Output: 9Q|13.3G
# ... this means: 9 Qubes running, total RAM consumption 13.3GB
# This script has to be placed in dom0 and must be made executable via chmod +x <FILENAME>
# suggested location ~/bin as this location is included in the PATH environment variable
# How to run:
# 
# The output of this script can be placed in the XFCE top bar, via:
#   1) Right Click on bar > Panel > Add new items > Generic Monitor
#   2) after adding the generic monitor plabel, right click on it and choose properties
#   3) add this script to the command field.
#
# Initial version 03.04.18 by https://github.com/one7two99
# 
ram_sum="("$(xl list | awk '{print $3}' | tail -n +2 | paste -s -d+ -)")/1000"
ram_sum=$(bc <<< "scale=1;$ram_sum")
qubes_sum=$(xl list 2> /dev/null | tail -n +2 | wc -l)
echo $qubes_sum"Q|"$ram_sum"G"
