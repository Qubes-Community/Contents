#!/bin/sh

# Title description:
## Universal Qubes Update Script (UQUS).

# Quick purpose overview:
## This script performs auto-updates of dom0 and every default template, as well as any templates
## you may wish to add. The script is straight forward and highly customizeable. 

# >>>>WARNING!<<<<
## Please read the script carefully, do not run if you do not know what it does.
## Be sure you edit it correctly to your own needs.

# >>>Disclaimer!<<<
## I take no responsibility for use of this script, please study it before you use this script at your own risk. 
## However I gureantee and stand by the ideal and belief to improve the quality and reliability as far as possible
## within my capability and reach, and reasonable circumstances, such as being aware, and having the time to fix it.

# Authors:
## Aekez @ https://github.com/Qubes-Community

# Feedback & Contributions:
## Feedback and/or new contributoers are welcome, please use QCC Pull Request, or feel free to contact me.

# Important usage notes:
##1) Be sure you have enough free RAM to run every updated template, all are run one at a time.
##2) The script will halt if it is interupted, such as not enoguh RAM, errors/logs are currently not reported.
##3) VMs will proceed and shutdown automatically if no updates, or after succesfull update install.
##4) You may include the -y option to auto-accept updates in some VMs, be careful though.
##5) Add or remove # in front of the command instructions to disable/enable commands.
##6) Its essential to keep dom0/templates in sync between repositories, don't mix current and current-testing.
##7) Only use current-testing if you know what you are getting yourself into (untested updates).
##8) This script release version is only tested on Qubes 4.0, but presumably may work on Qubes 3.2.

# To-do notes:
##1) Further streamline script, making it easier to customize with symbolic links.
##2) Reducing the risk that users mistakenly run testing, or out-of-sync dom0/template updates.
##3) If feasible, presenting the logs for each update, saved in a dated folder for every time script is run.
##    - If feasible, reporting errors and logs to the user during or after the update has finished.
##    - If succesful, it removes one of the two major concerns of including the -y attribute, making it easier to use.
##4) - (Done) Investigate whether --clean can be removed or changed from the dom0 update command.
##5) Investigate the feasibility of a simple GUI interface to select or de-select script script-options (possibly long-term).
##6) Fixing the progress bar, and picking the best approach to inform the user.
##7) A better means to stop the script pre-maturely but safely, because it is a long chain of events to update all VM's.



# Warning message:
## This warning meesage can be disabled with a #. It includes essential warning for new users
## not aware of the pitfalls of scripts. Its highly recommended that new users study how the
## script works, it's not very complicated, but also not straight simple either.
zenity --width="420" --height="200" --title="Welcome to UQUS!" --info --text='This script allows you to easily keep Qubes 4 in a good state with proper update maintenance.\n\n\- Warning! Please read the comments inside the script carefully before running this script, and remember to do your routine backups.\n' 2> /dev/null


xterm -e 'sudo qubes-dom0-update --refresh'
#xterm -e 'sudo qubes-dom0-update --enablerepo=qubes-dom0-current-testing --refresh'
wait
#echo -ne "$(tput setaf 4)($(tput setaf 6)#    $(tput setaf 4)) $(tput setaf 6)Dom0 update has finished.$(tput setaf 9)\n"
#wait

qvm-start fedora-28 #Needed to avoid premature qvm-run shutdown.
wait
qvm-run fedora-28 'xterm -e sudo dnf update --refresh'
wait
qvm-run fedora-28 'xterm -e sudo dnf upgrade'
wait
#qvm-run fedora-28 'xterm -e sudo dnf update --enablerepo=qubes-vm-*-current-testing --refresh'
#wait
#qvm-run fedora-28 'xterm -e sudo dnf upgrade --enablerepo=qubes-vm-*-current-testing'
#wait
#qvm-run fedora-28 'xterm -e sudo dnf autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
#wait
qvm-shutdown fedora-28 #Needed if qvm-start is used.
wait
#echo -ne "$(tput setaf 4)(#$(tput setaf 6)#   $(tput setaf 4)) $(tput setaf 6)Fedora-28 update has finished.$(tput setaf 9)\n"
#wait

qvm-start debian-9 #Needed to avoid premature qvm-run shutdown, important here.
wait
qvm-run debian-9 'xterm -e sudo apt-get update; xterm -e sudo apt-get dist-upgrade'
wait
#qvm-run debian-9 'xterm -e sudo apt-get update -t *-testing; xterm -e sudo apt-get dist-upgrade -t *-testing'
#wait
#qvm-run debian-9 'xterm -e sudo apt autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
wait
qvm-shutdown debian-9 #Needed if qvm-start is used.
wait
#echo -ne "$(tput setaf 4)(##$(tput setaf 6)#  $(tput setaf 4)) $(tput setaf 6)Debian-9 update has finished.$(tput setaf 9)\n"
#wait


qvm-start whonix-ws #Needed to avoid premature qvm-run shutdown, important here.
wait
qvm-run whonix-ws 'xterm -e sudo apt-get update; xterm -e sudo apt-get dist-upgrade'
wait
#qvm-run whonix-ws 'xterm -e sudo apt-get update -t *-testing; xterm -e sudo apt-get dist-upgrade -t *-testing'
#wait
#qvm-run whonix-ws 'xterm -e sudo apt autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
#wait
qvm-shutdown whonix-ws #Needed if qvm-start is used.
wait
#echo -ne "$(tput setaf 4)(###$(tput setaf 6)# $(tput setaf 4)) $(tput setaf 6)Whonix-WS update has finished.$(tput setaf 9)\n"
#wait

qvm-start whonix-gw #Needed to avoid premature qvm-run shutdown, important here.
wait
qvm-run whonix-gw 'xterm -e sudo apt-get update; xterm -e sudo apt-get dist-upgrade'
wait
#qvm-run whonix-gw 'xterm -e sudo apt-get update -t *-testing; xterm -e sudo apt-get dist-upgrade -t *-testing'
#wait
#qvm-run whonix-gw 'xterm -e sudo apt autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
#wait
qvm-shutdown whonix-gw #Needed if qvm-start is used.
wait
#echo -ne "$(tput setaf 4)(####$(tput setaf 6)#$(tput setaf 4)) $(tput setaf 6)Whonix-GW update has finished.$(tput setaf 9)\n"
#wait

#echo -ne "$(tput setaf 4)(#####) $(tput setaf 6)The uQUS script has finished.\n"
#echo -ne '\n'$(tput setaf 9)

#qvm-shutdown sys-whonix #Optional.
#wait

##Conclusion: Question message, whether to restart or not.
##For this part of the Script logic, credit goes to rhss6-2011 @ https://ubuntuforums.org/showthread.php?t=2239195
ans=$(zenity --width="420" --height="200" --title="uQUS has reached its conclusion." --question --text='The update-script has successfully reached its conflusion.\n\n- Click "Yes" to perform a full system restart.\n\n- Click "No" if no restart is required or you wish to restart manually later.\n\n- Normal template updates? It is recommended to restart VMs.\n- Qubes OS updates? It is recommended to perofmr a full system re-start.' --ok-label="Yes" --cancel-label="No" 2> /dev/null
if [ $? = 0 ] ; then
command=$(xterm -e shutdown -h now) #use 'reboot -h now' instead of shutdown if you want the 'Yes' button to perform a reboot.
else
command=$()
fi
)
