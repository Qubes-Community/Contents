#!/bin/sh

#Author:
#Aekez @ Github

#Disclaimer:
#Please use this script responsibly & at own risk.
#Please study the script, so that you know how it works.

#Tip:
#1) You may change the dom0 output folder ~/Screenshots if desired.
#2) mv "$()" and the -o option flag, autosaves screenshots.
#3) Put a longer or shorter sleep time if you need more or less time
#   to assign a screenshot region.
#4) A minimum sleep timer is adviced to ensure qvm-move works.
#5) screenshot_* moves all files named screenshot_ in that foler.

mv "$(xfce4-screenshooter -ro ls)" ~/Screenshots
 ( sleep 15 )
qvm-move-to-vm AppVM ~/Screenshots/Screenshot_*
