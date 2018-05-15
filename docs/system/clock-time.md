Understanding and fixing issues with time/clock in Qubes OS
===========================================================

*Note: the content here is for Qubes 4.0, some things may be different in Qubes 3.2.*

Architecture
------------

### Timezone ###

The system's timezone is set in dom0. 

VMs can read the system's timezone value from dom0 through the [QubesDB](https://www.qubes-os.org/doc/vm-interface/#qubesdb) `qubes-timezone` key. On Linux VMs with `qubes-core-agent` installed the time zone is set at boot time by the `/usr/lib/qubes/init/qubes-early-vm-config.sh` script.


### Clock synchronization ###

A VM is defined globally as "clockVM", from which other VMs and dom0 will synchronize their clock with. The following command in dom0 shows which VM is defined:

~~~
qubes-prefs clockvm
~~~

By default the clockvm is sys-net. The clockVM's clock is synchronized with remote NTP servers automatically by the `systemd-timesyncd` service.

The clockVM has the `clocksync` [Qubes service](https://www.qubes-os.org/doc/qubes-service/) enabled (as shown by `qvm-service` or in the Services tab in sys-net Qubes Setting GUI): various scripts and systemd service definitions test for the presence (or absence) of `/var/run/qubes-service/clocksync` to differentiate the clockVM from other VMs, which allows the clockVM to be based on the same template than other VMs.

Clock synchonization in other VMs is done:

- at boot time, by the `qubes-sync-time` service
- after suspend, by `/etc/qubes/suspend-post.d/qvm-sync-clock.sh`
- every 6 hours, by the `qubes-sync-time.timer` systemd timer

Those scripts run `/usr/bin/qvm-sync-clock` which uses the `qubes.GetDate` [RPC](https://www.qubes-os.org/doc/qrexec3/#qubes-rpc-services) call to obtain the date from the clockVM  and run `/usr/lib/qubes/qubes-sync-clock` to validate the data received and set the date.

Clock synchonization in dom0 is done by the `/etc/cron.d/qubes-sync-clock.cron` cron job run every hour, which calls `/usr/bin/qvm-sync-clock` (despite scripts having the same filename in dom0 and VMs, they are different, but the end result is the same: `qubes.GetDate` RPC call, innput validation, and setting the date).


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

