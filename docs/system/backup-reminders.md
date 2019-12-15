Display a reminder when it's been more than N days since a backup
=================================================================

Backups are important, regular ones doubly so. Unfortunately it's very easy to forget to make regular backups. Since Qubes stores the date and time when a VM was backed up, we will use this information to remind the user (probably you) when it has been more than N days since a backup.

Architecture
------------

We create a shell script that:
- compiles the list of VMs which we care about ensuring regular backups for,
- determines the oldest backup timestamp for those VMs,
- checks how far that timestamp is in the past, and
- if that timestamp is older than a threshold, pops up a notification in dom0.

We use an "exclude file" to exclude some VMs which we don't backup, and therefore for which we should not check timestamps for.

Since we're probably running on a laptop, we run the script daily using `anacron` instead of `cron`, since `anacron` will deal with situtions when the machine is frequently in "suspend" mode. (Which laptops are)

We set up an anacrontab for our user (as opposed to using a system-wide one) and run `anacron` hourly using the user's `crontab`. This gives some minor security benefits (by not running things as root) and reduces the chance of accidentally causing problems in the system through misconfiguration.


Implementation
--------------

#### Excludes file ####

A plain text file containing the names of VMs which are not backed up. In this example, we save it in dom0, `/home/${USER}/backup/exclude_vms.txt`:
```
fedora-30
whonix-gw-15
whonix-ws-15
```
(you'll need to change as needed depending on your backup policy)

#### Backup script ####

Put this in dom0, probably in `/home/${USER}/backup/remind.sh`:
```
#!/bin/bash

# Remind if this many days since backup
DAYS_THRESHOLD=3

# Setup variables
BACKUP_DIR="/home/${USER}/backup"
EXCLUDE_FILE=${BACKUP_DIR}/exclude_vms.txt


# Build backup VM list
ALL_VMS=(`/usr/bin/qvm-ls --raw-list`)
EXCLUDE_VMS=(`/usr/bin/cat $EXCLUDE_FILE`)
EXCLUDE_VMS+=("dom0")
BACKUP_VMS=()
for i in "${ALL_VMS[@]}"; do
        skip=
        for j in "${EXCLUDE_VMS[@]}"; do
                [[ $i == $j ]] && { skip=1; break; }
        done
        [[ -n $skip ]] || BACKUP_VMS+=("$i")
done

# Get oldest known backup TS
TS=`/usr/bin/date +%s`
echo "TS now: $TS"
for vm in "${BACKUP_VMS[@]}"; do
        vm_ts=`/usr/bin/qvm-prefs --get $vm backup_timestamp`
        
        if [ "$vm_ts" -lt "$TS" ]; then
                echo "New oldest TS: $vm_ts"
                TS=$vm_ts
        fi
done

# Get delta between current time and oldest backup
NOW=`/usr/bin/date +%s`
DELTA=`/usr/bin/expr $NOW - $TS`
DELTA_DAYS=`/usr/bin/expr $DELTA / 86400`
echo "delta in seconds: $DELTA / days: $DELTA_DAYS"
if [ "$DELTA_DAYS" -gt "$DAYS_THRESHOLD" ]; then
        /usr/bin/notify-send --expire-time 86400000 "It has been $DELTA_DAYS days since last backup"
fi

echo `/usr/bin/date` >> $BACKUP_DIR/reminders.log
remind.sh (END)
```

Then mark it as executable with `chmod +x /home/${USER}/backup/remind.sh`.

You can try running it right away to see how long it's been since your last backup.


#### Anacrontab ####

Anacron should be installed by default in dom0, but you can check it by running (in dom0): `dnf info cronie-anacron` and verifying the first line of the info is "Installed Packages".

First some basic configuration:
1. Make sure we have a .config directory: `mkdir -p ~/.config`
1. Create an anacrontab file for your user: `touch ~/.config/anacrontab`
1. Make sure we have a ~/.var/spool/anacron directory: `mkdir -p ~/.var/spool/anacron/`

Now open up the file `${HOME}/.config/anacrontab` in your text editor of choice and add to it the following, replacing USERNAME_GOES_HERE with the dom0 user account name (to find it, `echo ${USER}`:
```
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=USERNAME_GOES_HERE
# the maximal random delay added to the base delay of the jobs
RANDOM_DELAY=45
# the jobs will be started during the following hours only
START_HOURS_RANGE=3-22

#period in days   delay in minutes   job-identifier   command
@daily 0        backup-reminder /home/USERNAME_GOES_HERE/backup/remind.sh
```

#### Crontab ####

Finally, add the following to your crontab file, accessed by running `crontab -e`: (`crontab -e` is the only way you should access your crontab)

```
@hourly /usr/sbin/anacron -t ${HOME}/.config/anacrontab -S ${HOME}/.var/spool/anacron
```
