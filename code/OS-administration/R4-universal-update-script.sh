#!/bin/sh

# >>>>Title<<<<
## Universal Qubes Update Script (UQUS).

# >>>>Purpose<<<<
## This script performs auto-updates of dom0 and every default template, as well as any templates
## you may wish to add. The script is straight forward and highly customizeable. 

# >>>>WARNING!<<<<
## Please read the script carefully, do not run if you do not know what it does.
## Be sure you edit it correctly to your own needs.
## Useage notes and to-do-notes can be found at the bottom of the script.

# >>>Disclaimer!<<<
## I take no responsibility for use of this script, please study it before you use this script at your own risk. 
## However I gureantee and stand by the ideal and belief to improve the quality and reliability as far as possible
## within my capability and reach, and reasonable circumstances, such as being aware, and having the time to fix it.




# /// Testing Updates \\\
## Removing or inserting the hash-# sign on below lines will disable/enable Qubes testing updates.
## If using testing repositories, make sure you keep all domains (Dom0 and DomUs') in sync.
#dom0_testing='--enablerepo=qubes-dom0-current-testing'
#fedora_testing='--enablerepo=qubes-vm-*-current-testing' # Includes all CentOS and Fedora-Minimal templates.
#debian_testing='-t *-testing' # Includes all Whonix templates.

# /// Dom0 updates \\\
xterm -e 'sudo qubes-dom0-update '$dom0_testing' --refresh'
wait

# /// Template Script slots \\\
## You can insert values in the slots below, and/or add more slots in the script.
## Be sure you match the slots with the commands and values further down the script.
## Disabling a slot with hash-#, will disable updates for specified VM.

# Fedora_based script slots include all Fedora, Fedora-minimal and CentOS templates.
fedora_based_template_1='fedora-28'
#fedora_based_template_2=''
#fedora_based_template_3=''
#fedora_based_template_4=''
#fedora_based_template_5=''

# Debian_based script slots include all Debian / Whonix templates. 
debian_based_template_1='debian-9'
#debian_based_template_2=''
#debian_based_template_3=''
debian_based_template_4='whonix-ws'
debian_based_template_5='whonix-gw'




# /// Inner Script mechanics below \\\
# You only need to modify the below if you plan to go beyond the normal scope 
# of the scripts purpose, and/or if you want to expand the number of included slots.
# All fedora-based, and all debian-based slots are identical, except for slot numbers.
# It is therefore very easy to copy/paste to create more slots, and modify extra numbers.

# Fedora/Fedora-minimal/CentOS-based update slot #1
qvm-start "$fedora_based_template_1" #Needed to avoid premature qvm-run shutdown.
wait
qvm-run "$fedora_based_template_1" 'xterm -e sudo dnf update '$fedora_testing' --refresh'
wait
qvm-run "$fedora_based_template_1" 'xterm -e sudo dnf upgrade '$fedora_testing''
wait
#qvm-run "$fedora_based_template_1" 'xterm -e sudo dnf autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
#wait
qvm-shutdown "$fedora_based_template_1" #Needed if qvm-start is used.
wait

# Fedora/Fedora-minimal/CentOS-based update slot #2
qvm-start "$fedora_based_template_2" #Needed to avoid premature qvm-run shutdown.
wait
qvm-run "$fedora_based_template_2" 'xterm -e sudo dnf update '$fedora_testing' --refresh'
wait
qvm-run "$fedora_based_template_2" 'xterm -e sudo dnf upgrade '$fedora_testing''
wait
#qvm-run "$fedora_based_template_2" 'xterm -e sudo dnf autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
#wait
qvm-shutdown "$fedora_based_template_2" #Needed if qvm-start is used.
wait

# Fedora/Fedora-minimal/CentOS-based update slot #3
qvm-start "$fedora_based_template_3" #Needed to avoid premature qvm-run shutdown.
wait
qvm-run "$fedora_based_template_3" 'xterm -e sudo dnf update '$fedora_testing' --refresh'
wait
qvm-run "$fedora_based_template_3" 'xterm -e sudo dnf upgrade '$fedora_testing''
wait
#qvm-run "$fedora_based_template_3" 'xterm -e sudo dnf autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
#wait
qvm-shutdown "$fedora_based_template_3" #Needed if qvm-start is used.
wait

# Fedora/Fedora-minimal/CentOS-based update slot #4
qvm-start "$fedora_based_template_4" #Needed to avoid premature qvm-run shutdown.
wait
qvm-run "$fedora_based_template_4" 'xterm -e sudo dnf update '$fedora_testing' --refresh'
wait
qvm-run "$fedora_based_template_4" 'xterm -e sudo dnf upgrade '$fedora_testing''
wait
#qvm-run "$fedora_based_template_4" 'xterm -e sudo dnf autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
#wait
qvm-shutdown "$fedora_based_template_4" #Needed if qvm-start is used.
wait

# Fedora/Fedora-minimal/CentOS-based update slot #5
qvm-start "$fedora_based_template_5" #Needed to avoid premature qvm-run shutdown.
wait
qvm-run "$fedora_based_template_5" 'xterm -e sudo dnf update '$fedora_testing' --refresh'
wait
qvm-run "$fedora_based_template_5" 'xterm -e sudo dnf upgrade '$fedora_testing''
wait
#qvm-run "$fedora_based_template_5" 'xterm -e sudo dnf autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
#wait
qvm-shutdown "$fedora_based_template_5" #Needed if qvm-start is used.
wait





# Debian/Whonix-based update slot #1
qvm-start "$debian_based_template_1" #Needed to avoid premature qvm-run shutdown, important here.
wait
qvm-run "$debian_based_template_1" 'xterm -e sudo apt-get update '$debian_testing'; xterm -e sudo apt-get dist-upgrade '$debian_testing''
wait
#qvm-run "$debian_based_template_1" 'xterm -e sudo apt autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
wait
qvm-shutdown "$debian_based_template_1" #Needed if qvm-start is used.
wait

# Debian/Whonix-based update slot #2
qvm-start "$debian_based_template_2" #Needed to avoid premature qvm-run shutdown, important here.
wait
qvm-run "$debian_based_template_2" 'xterm -e sudo apt-get update '$debian_testing'; xterm -e sudo apt-get dist-upgrade '$debian_testing''
wait
#qvm-run "$debian_based_template_2" 'xterm -e sudo apt autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
wait
qvm-shutdown "$debian_based_template_2" #Needed if qvm-start is used.
wait

# Debian/Whonix-based update slot #3
qvm-start "$debian_based_template_3" #Needed to avoid premature qvm-run shutdown, important here.
wait
qvm-run "$debian_based_template_3" 'xterm -e sudo apt-get update '$debian_testing'; xterm -e sudo apt-get dist-upgrade '$debian_testing''
wait
#qvm-run "$debian_based_template_3" 'xterm -e sudo apt autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
wait
qvm-shutdown "$debian_based_template_3" #Needed if qvm-start is used.
wait

# Debian/Whonix-based update slot #4
qvm-start "$debian_based_template_4" #Needed to avoid premature qvm-run shutdown, important here.
wait
qvm-run "$debian_based_template_4" 'xterm -e sudo apt-get update '$debian_testing'; xterm -e sudo apt-get dist-upgrade '$debian_testing''
wait
#qvm-run "$debian_based_template_4" 'xterm -e sudo apt autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
wait
qvm-shutdown "$debian_based_template_4" #Needed if qvm-start is used.
wait

# Debian/Whonix-based update slot #5
qvm-start "$debian_based_template_5" #Needed to avoid premature qvm-run shutdown, important here.
wait
qvm-run "$debian_based_template_5" 'xterm -e sudo apt-get update '$debian_testing'; xterm -e sudo apt-get dist-upgrade '$debian_testing''
wait
#qvm-run "$debian_based_template_5" 'xterm -e sudo apt autoremove' # Remember you are asked to confirm for a reason, it may not always be a good to autoremove.
wait
qvm-shutdown "$debian_based_template_5" #Needed if qvm-start is used.
wait





#qvm-shutdown sys-whonix #Optional.
#wait

##Conclusion: Question message, whether to restart or not.
##For this part of the Script logic, credit goes to rhss6-2011 @ https://ubuntuforums.org/showthread.php?t=2239195
ans=$(zenity --width="420" --height="200" --title="uQUS has reached its conclusion." --question --text='The update-script has successfully reached its conflusion.\n\n- Click "Yes" to perform a full system restart.\n\n- Click "No" if no restart is required or you wish to restart manually later.\n\n- It is recommended to minimum restart all AppVMs aftere template updates.\n- If dom0 Qubes OS updates were involved, then it is highly recommended to perform a full system re-start.\n- It may not always clear-cut when a full system restart is needed or not, to be safe just restart the full system.' --ok-label="Yes" --cancel-label="No" 2> /dev/null
if [ $? = 0 ] ; then
command=$(xterm -e shutdown -h now) #use 'reboot -h now' instead of shutdown if you want the 'Yes' button to perform a reboot.
else
command=$()
fi
)


# >>>>usage-notes!<<<<
##1) Be sure you have enough free RAM to run every updated template, all are run one at a time.
##2) The script will halt if it is interupted, such as not enoguh RAM, errors/logs are currently not reported.
##3) VMs will proceed and shutdown automatically if no updates, or after succesfull update install.
##4) You may include the -y option to auto-accept updates in some VMs, be careful though.
##5) Add or remove # in front of the command instructions to disable/enable commands.
##6) Its essential to keep dom0/templates in sync between repositories, don't mix current and current-testing.
##7) Only use current-testing if you know what you are getting yourself into (untested updates).
##8) This script release version is only tested on Qubes 4.0, but presumably may work on Qubes 3.2.

# >>>>To-do-notes<<<<
##1) Further streamline script, making it easier to customize with symbolic links.
##2) Reducing the risk that users mistakenly run testing, or out-of-sync dom0/template updates.
##3) If feasible, presenting the logs for each update, saved in a dated folder for every time script is run.
##    - If feasible, reporting errors and logs to the user during or after the update has finished.
##    - If succesful, it removes one of the two major concerns of including the -y attribute, making it easier to use.
##4) - (Done) Investigate whether --clean can be removed or changed from the dom0 update command.
##5) Investigate the feasibility of a simple GUI interface to select or de-select script script-options (possibly long-term).
##6) Fixing the progress bar, and picking the best approach to inform the user.
##7) A better means to stop the script pre-maturely but safely, because it is a long chain of events to update all VM's.

# >>>>Author<<<<
## Aekez @ https://github.com/Qubes-Community

# >>>>Feedback & Contributions<<<<
## Feedback and/or new contributoers are welcome, please use QCC Pull Request, or feel free to contact me.
