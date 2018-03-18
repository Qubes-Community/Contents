#!/bin/sh

#Author:
#Aekez @ Github

#Disclaimer:
#Please use this script responsibly & at own risk.
#Please study the script, so that you know how it works.

wid=$(xdotool search --name 'Mozilla Firefox')
wmctrl -i -r $wid -b toggle,fullscreen

