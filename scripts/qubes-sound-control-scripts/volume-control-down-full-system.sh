#!/bin/sh

#Author:
#Aekez @ Github

#Disclaimer:
#Please use this script responsibly & at own risk.
#Please study the script, so that you know how it works.

#Tips:
#1) Change 0 to the sink output you are using.
#2) You can change the % value to a fixed value.
#3) If pactl isn't installed, then you need to install
#   pulseaudio-utils in dom0.
#   'sudo qubes-dom0-update pulseaudio-utils'

pactl set-sink-volume 0 -20%
