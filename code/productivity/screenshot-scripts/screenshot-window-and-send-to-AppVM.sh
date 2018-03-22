#!/bin/sh

#Author:
#Aekez @ Github

#Disclaimer:
#Please use this script responsibly & at own risk.
#Please study the script, so that you know how it works.

#Tip:
#1) You may change the dom0 output folder ~/Screenshots if desired.
#2) mv "$()" and the -o option flag, autosaves screenshots.
#3) Put a longer sleep time if you need to prepare.
#4) A minimum sleep timer is adviced to ensure qvm-move works.
#5) screenshot_* moves all files named screenshot_ in that foler.

mv "$(xfce4-screenshooter -wo ls)" ~/Screenshots
 ( sleep 3 )
qvm-move-to-vm AppVM ~/Screenshots/screenshot_*
