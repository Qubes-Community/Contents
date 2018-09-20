Understanding and fixing issues with time/clock in Qubes OS
===========================================================

*Note: the content here is for Qubes 4.0, some things may be different in Qubes 3.2.*

Architecture
------------

### Timezone ###

The system's timezone is set in dom0. 

VMs can read the system's timezone value from dom0 through the [QubesDB](https://www.qubes-os.org/doc/vm-interface/#qubesdb) `qubes-timezone` key. On Linux VMs with `qubes-core-agent` installed the time zone is set at boot time by the `/usr/lib/qubes/init/qubes-early-vm-config.sh` script.


### Clock synchronization ###

#### "ClockVM" ####

One of the VMs is defined globally as "clockVM", from which other VMs and dom0 will synchronize their clock with. The following command in dom0 shows which VM has this role:

~~~
qubes-prefs clockvm
~~~

By default the clockVM is sys-net. Its clock is synchronized with remote NTP servers automatically by the `systemd-timesyncd` service.

The clockVM has the `clocksync` [Qubes service](https://www.qubes-os.org/doc/qubes-service/) enabled (as shown by `qvm-service` or in the Services tab in sys-net Qubes Setting GUI). This allows various scripts and systemd service definitions to test for the presence (or lack thereof) of `/var/run/qubes-service/clocksync` to differentiate the clockVM from other VMs. This in turn allows the clockVM to be based on the same template that other VMs use.

#### VMs (other than ClockVM) ####

Clock synchonization happens:

- at boot time (`qubes-sync-time` systemd service)
- after suspend (`/etc/qubes/suspend-post.d/qvm-sync-clock.sh`)
- every 6 hours (`qubes-sync-time.timer` systemd timer)

Those scripts run `/usr/bin/qvm-sync-clock` which uses the `qubes.GetDate` [RPC](https://www.qubes-os.org/doc/qrexec3/#qubes-rpc-services) call to obtain the date from the clockVM  and run `/usr/lib/qubes/qubes-sync-clock` to validate the data received and set the date.

#### Dom0 ####

Clock synchonization in dom0 is done by the `/etc/cron.d/qubes-sync-clock.cron` cron job every hour, which calls `/usr/bin/qvm-sync-clock`. Note that despite having the same name the `qvm-sync-clock` script in dom0 is different from the one installed in VMs; however it performs the same actions - using the `qubes.GetDate` RPC call, input validation and setting the date.


Tweaking time synchronization defaults
--------------------------------------

### VMs ###

(Re)setting the clock every 6 hours might not be accurate enough for some software. There are basically two ways to improve it:

- disable the timer and run a ntp client; that is the best solution for time accuracy but it increases the attack surface considerably.
- change the definition of the systemd timer so that it's run more frequently.

The latter is simply a matter of putting the following definition in `/etc/systemd/system/qubes-sync-time.timer`:

~~~
[Timer]
OnUnitActiveSec=10min
~~~

Doing so overrides the relevant definitions in `/usr/lib/systemd/system/qubes-sync-time.timer` and prevents the changes from being overwritten by the next `qubes-core-agent-systemd` package upgrade.

To test, reload the definitions with `sudo systemctl daemon-reload` and check the timers' status with `systemctl list-timers`.

If you want those changes to stick after a reboot, apply them in the TemplateVM you're using for your AppVM; alternatively you could put the systemd definition file in to your AppVM's `/rw/config` folder and use the `/rw/config/rc.local` script to copy the definition file to `/etc/systemd/system/qubes-sync-time.timer` and issue a `systemctl daemon-reload` command.


### Dom0 ###

Simply change the cron "frequency" in `/etc/cron.d/qubes-sync-clock.cron`. This might not survive updates of the `qubes-core-dom0-linux` package though. If that's the case, one could add a cron job that runs `qvm-sync-clock` more often, in addition to the original `/etc/cron.d/qubes-sync-clock.cron` cron job.


Debugging problems
------------------

### Time off by X hours ###

A common issue is to have the time off by a number of hours. There are usually two causes:

- Wrong configured timezone.
- MS Windows was used before installing Qubes OS (or in the case of dual-boot installations). Windows stores the time in the hardware clock as "local time" while Linux stores the time as UTC.

To check that the timezone is OK in dom0, run `timedatectl`. Alternatively, look at the `/etc/localtime` symlink: it should point to a timezone in `/usr/share/zoneinfo`. If you need to change the timezone in dom0, you can use

~~~
sudo timedatectl set-timezone "Australia/Queensland"
~~~

or

~~~
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/Australia/Queensland /etc/localtime
~~~

To set the system's hardware clock to UTC, run the following command in the clockVM (usually sys-net):

~~~
sudo hwclock --systohc --utc
~~~

Then the easiest way to have the changes applied to all VMs is to do a full reboot.


### Wrong time/date ###

It is also possible that the clockVM's clock isn't properly synchronized with remote NTP servers. Check the status of the systemd-timesyncd service with `systemctl status systemd-timesyncd` in the clockVM (usuall sys-net):

~~~
● systemd-timesyncd.service - Network Time Synchronization
   Loaded: loaded (/usr/lib/systemd/system/systemd-timesyncd.service; enabled; vendor preset: enabled)
  Drop-In: /usr/lib/systemd/system/systemd-timesyncd.service.d
           └─30_qubes.conf
   Active: active (running) since Sun 2018-04-29 06:59:59 EEST; 1 weeks 1 days ago
     Docs: man:systemd-timesyncd.service(8)
 Main PID: 16966 (systemd-timesyn)
   Status: "Synchronized to time server 95.87.227.232:123 (0.fedora.pool.ntp.org)."
    Tasks: 2 (limit: 4915)
   CGroup: /system.slice/systemd-timesyncd.service
           └─16966 /usr/lib/systemd/systemd-timesyncd
~~~

In the output above, the clock was successfully synchronized with the `0.fedora.pool.ntp.org` server. The output might be empty if logs were rotated though, in that case restart the service with `systemctl restart systemd-timesyncd` and recheck its status.

No clock synchronization usually means the clockVM has a problem with networking.

