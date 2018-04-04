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
xl list | awk '
	BEGIN { mem=0; qubes=0; }
	/ [0-9]+ +[0-9]+ +[0-9]+ / { mem+=$3; qubes++; }
	END { printf("%dQ|%.1fG\n", qubes, mem/1000); }'
