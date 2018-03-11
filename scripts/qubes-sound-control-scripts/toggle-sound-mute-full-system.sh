#!/bin/sh

#Author:
#Aekez @ Github

#Disclaimer:
#Please use this script responsibly & at own risk.
#Please study the script, so that you know how it works.

#Tips:
#1) Change 0 if you are using a different sink sound output.
#2) Change toggle to 1 if you want to only enable the sound, not toggle.
#3) Change toggle to 0 if you want to only disable all sounds, not toggle.
#4) If pactl isn't installed, then you need to install
#   pulseaudio-utils in dom0.
#   'sudo qubes-dom0-update pulseaudio-utils'

pactl set-sink-input-mute 0 toggle
