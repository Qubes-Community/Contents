#!/bin/sh

#Title description
##Unofficial Qubes Maintenance Updater (uQMU).

#>>>>WARNING!<<<<
##Please read the script carefully, do not run if you do not know what it does.
##Be sure you edit it correctly to your own needs.

#Disclaimer:
## - At this point in time, this script has not been quality reviewed.
## - Feel free to critesize by suggesting constructive improvements, or by commit to
##   the script on github.
## - We, or I, take no responsibility for use of this script, please study it before
##   you use this unfinished script at your own risk.

#Authors:
##Aekez @ https://github.com/Qubes-Community

#Quick purpose overview:
## This script performs auto-updates of dom0 and every default template. The script is
## highly customizeable, warning message/Quick-Backup/repositories, can be adjusted or
## disabled. It also includes a quick optional qvm-backup reminder/starter. If you use
## backup profiles instead of manually configuring which VMs to include or exclude in
## the qvm-backup, then all you need to do is to adjust the qvm-backup command below,
## similar to how you normally would execute the command in dom0 terminal.

#Important notes
##1) Be sure you have enough free RAM to run the largest RAM intensive template, one at a time.
##2) The script will halt if it is interupted, such as not enoguh RAM.
##3) VMs will shutdown automatically if no updates, or after succesfull update install.
##4) You may include the -y option to auto-accept updates in some VMs, be careful though.
##5) You can disable the Quick Backup, however if you use it then remember to configure it.
##6) Add or remove # in front of the command instructions to disable/enable commands.
##7) Its essential to keep dom0/templates in sync between repositories.
##8) Repositories must be in sync, such as between stable & current-testing for dom0/tempaltes.
##9) Only use current-testing if you know what you are getting yourself into (untested updates).
#10) This script release version is only tested on Qubes 4.0.

#Warning message
##This warning meesage can be disabled with a #. It includes essential warning for new users
##not aware of the pitfalls of scripts. Its highly recommended that new users study how the
##script works, it's not very complicated, but also not straight simple either.
zenity --width="420" --height="200" --title="Welcome to uQMU!" --info --text='This script allows you to easily keep Qubes 4 in a good state with proper update maintenance.\n\n\- Warning! Please read the comments inside the script carefully before running this script.\n\n- The script is out-of-the-box safety locked, you need to edit the "#" to enable features. Quick Backup and Reboot prompt are by default enabled, as you will notice when you click "ok" below, however requires an address path and target BackupVM. Please decline the next two prompts, and then edit the script for your needs.\n\n Please do not use Quick Backup before you manually adjusted it to your needs inside the script.' 2> /dev/null
wait


#Quick Backup Redundancy
##The purpose here is to serve as a reminder to backup before performing updates. Updates always
##carry a risk of making the system unbootable. This serves as a popup message, which you
##can decline to continue without starting qvm-backup, or click yes to perform your qvm-backup.
##Keep in mind you need to adjust it below to your own customized qvm-backup. The default will
##only exclude system dom0 & default templates. However a proper path/src-VM is still required.
##Remember to put the backup externally, so that you can access it if the system does not boot.
##Partial credit for this section rhss6-2011 @ https://ubuntuforums.org/showthread.php?t=2239195
ans=$(zenity --width="420" --height="200" --title="Welcome to uQMU!" --question --text='Must have sufficient free RAM to run the uQMU.\n\nPllease select if you want to perform a pre-selected AppVM backup. To execute a backup profile, or specific inclusion/exclusion of VMs, can be modified and standardized within the script.' --ok-label="Yes" --cancel-label="No" 2> /dev/null
if [ $? = 0 ] ; then
command=$(xterm -e 'sudo qvm-backup -d add-VM-name-here "/home/user/" -x fedora-26 -x debian-9 -x whonix-ws -x whonix-gw -x sys-net -x sys-firewall -x sys-usb -x sys-whonix -x fedora-26-dvm -x whonix-ws-dvm -x anon-whonix')
else
command=$()
fi
)
wait


##Qubes dom0 updates
#xterm -e 'sudo qubes-dom0-update --clean'
#xterm -e 'sudo qubes-dom0-update --enablerepo=qubes-dom0-current-testing --clean'
wait
echo -ne "$(tput setaf 4)($(tput setaf 6)#    $(tput setaf 4)) $(tput setaf 6)Dom0 update has finished.$(tput setaf 9)\n"
wait


##Default Qubes fedora template - Only enable one repository, and keep the same type across all templates/dom0.
#qvm-start fedora-26 #Needed to avoid premature qvm-run shutdown.
wait
#qvm-run fedora-26 'xterm -e sudo dnf update --refresh'
#qvm-run fedora-26 'xterm -e sudo dnf update --enablerepo=qubes-vm-*-current-testing --refresh'
wait
#qvm-shutdown fedora-26 #Needed if qvm-start is used.
wait
echo -ne "$(tput setaf 4)(#$(tput setaf 6)#   $(tput setaf 4)) $(tput setaf 6)Fedora-26 update has finished.$(tput setaf 9)\n"
wait


##Default Qubes debian template.
##To enable Qubes debian current-testing equivalent, edit debian $ /etc/apt/sources.list.d/qubes-*.list
#qvm-start debian-9 #Needed to avoid premature qvm-run shutdown, important here.
wait
#qvm-run debian-9 'xterm -e sudo apt-get update'
wait
#qvm-run debian-9 'xterm -e sudo apt-get dist-upgrade'
wait
#qvm-shutdown debian-9 #Needed if qvm-start is used.
wait
echo -ne "$(tput setaf 4)(##$(tput setaf 6)#  $(tput setaf 4)) $(tput setaf 6)Debian-9 update has finished.$(tput setaf 9)\n"
wait



##Default Qubes Whonix-WS.
##To enable Qubes debian current-testing equivalent, edit debian $ /etc/apt/sources.list.d/qubes-*.list
#qvm-start whonix-ws #Needed to avoid premature qvm-run shutdown, important here.
wait
#qvm-run whonix-ws 'xterm -e sudo apt-get update'
wait
#qvm-run whonix-ws 'xterm -e sudo apt-get dist-upgrade'
wait
#qvm-shutdown whonix-ws #Needed if qvm-start is used.
wait
echo -ne "$(tput setaf 4)(###$(tput setaf 6)# $(tput setaf 4)) $(tput setaf 6)Whonix-WS update has finished.$(tput setaf 9)\n"
wait


##Default Qubes Whonix-GW. Keep both commands enabled.
##To enable Qubes debian current-testing equivalent, edit debian $ /etc/apt/sources.list.d/qubes-*.list
#qvm-start whonix-gw #Needed to avoid premature qvm-run shutdown, important here.
wait
#qvm-run whonix-gw 'xterm -e sudo apt-get update'
wait
#qvm-run whonix-gw 'xterm -e sudo apt-get dist-upgrade'
wait
#qvm-shutdown whonix-gw #Needed if qvm-start is used.
wait
echo -ne "$(tput setaf 4)(####$(tput setaf 6)#$(tput setaf 4)) $(tput setaf 6)Whonix-GW update has finished.$(tput setaf 9)\n"
wait

echo -ne "$(tput setaf 4)(#####) $(tput setaf 6)The uQMU script has finished.\n"
echo -ne '\n'$(tput setaf 9)
wait

#qvm-shutdown sys-whonix #Optional.
#wait

##Conclusion: Question message, whether to restart or not. Copied logic, credit goes
##to rhss6-2011 @ https://ubuntuforums.org/showthread.php?t=2239195
ans=$(zenity --width="420" --height="200" --title="uQMU has reached its conclusion." --question --text='The update-script has successfully reached its conflusion.\n\n- Click "Yes" to perform a full system restart.\n\n- Click "No" if no restart is required or you wish to restart manually later.' --ok-label="Yes" --cancel-label="No" 2> /dev/null
if [ $? = 0 ] ; then
command=$(xterm -e shutdown -h now) #use 'reboot -h now' instead of shutdown if you want the 'Yes' button to perform a reboot.
else
command=$()
fi
)

#done

