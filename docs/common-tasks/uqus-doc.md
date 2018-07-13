

### 1) Introduction
UQUS (Universal Qubes Update Script) is a script made to make it easy to update TemplateVM's and StandaloneVM's in Qubes 4.0, however 
it may also be useful for Qubes 3.2. (Currently need 3.2. testers).
  - **NOTE!!** Newst version of UQUS is currently not yet uploaded, but it will be uploaded soon. For example current version of UQUS has no 
  autonomouse detection, nor any logging capability. Some extra work is needed before its ready. Stay tuned for an update. 
  **This doc is written for the upcoming UQUS version.**

<br />

### 2) Feature: Autonomouse dectection of TemplateVM's and StandaloneVM's.
UQUS will automatically find your TemplateVM's and StandaloneVM's containing the primary template OS name. 
For example, any TemplateVM or standaloneVM containing the word "fedora", "debian", or "whonix", will 
update separately in order to make up for their differences in the update process. 
  - It is normally possible to update all TemplateVM and StandaloneVM's irregardless of their VM names, please see 
  the limitations section below as for why UQUS has this minor limiation. It is deemed a minor limitation because 
  templates normally always include their OS name in the VM-name anyway, however steps are taken to allow user different
  choices to overcome this issue, should you have given your TemplateVM or StandaloneVM a unique name.

<br />

### 3) Feature: LogVM - Logging all update/upgrade/autoremove transactions.
UQUS supports a low-system-resource "one-way" centralized offline LogVM, which is strictly used for logging and nothing else. 
The benifit is that you can keep all your logs gathered at a single location, which neither needs much RAM
to run, nor much disk space to preserve a long history of logs.
  - Security: The LogVM is an offline based AppVM, with strict inter-VM Qubes-RPC (Policy) restrictions. This means
  that neither the LogVM, nor the StandaloneVM's or TemplateVM's, have direct internet access at any time, nor does
  the LogVM ever import anything else but logs, so that the risk of malware being imported to the LogVM is low. Furthermore
  transactions are restricted in one-direction, so templateVM's can never be accessed despite of moving logs to a centralized LogVM.
  The biggest limitation to this security model for LogVM's, is if the user puts a wrong Qubes-RPC (Policy). Changing Qubes-RPC may
  one day become autnomous in UQUS, however it depends greatly if the script will remain located in dom0, or be moved to a less trusted VM.
  Accessing dom0 from a less trusted domain is not desured, however options for future UQUS updates are still being considered here.

<br />


### 4) Feature: Autonomous error detection.
Having all update/upgrade/autoremove logs centralized in the LogVM, allows for a single procress to monitor for errors. This is potentially still
some months into the future, however it is a major goal, and is therefore included.
- Error detection will primarily be simple and based on searching for words like "danger, dangerours, critical, critically, fail, failed, unable, and similar words that indicate errors, and autonomously present it in an easy to read manner.
  - Currently this can only be done manually in the LogVM, however the log history is preserved and future log detection processes can later be run on older historic logs.
  - Autonomous error-detection "could" potentially mean less risk by running -y autoaccept on updates and upgrades, however only "less risky".
  - Autonomous support for autoremove will on-purpose remain unsupported.
  - Autonomous error-detection may be more complicated than estimated, however stay tuned for now.

<br />

### 5) Feature: Central log-window output for awareness of how UQUS is progressing.
The central output window has multiple of different benifits, as following:
- Shows live which TemplateVM and StandaloneVM is being updated.
- Shows which commands are in current-time being executed.
- Shows how far the UQUS update script has progressed.
- Written so it is made easy to read and keep track of the log-window progressive content.
- Output from the central log-window is also moved to the LogVM.
  - This happens when UQUS finishes, or if any different script-command fails mid-way.
- Central window includes basic UQUS information, including how to stop the script (i.e. running `kill -9 pid) and also includes the scripts current PID number so you don't need to go looking for it yourself.
  - In the future keybinds may be included to pause or stop UQUS, which can be modified to different keys in the script.

<br />

### 6) Feature: UQUS seeks and provides high flexibility to settings and prefferences.
A persistent goal is to make UQUS allow easy and effortless user modifications - as far possible. UQUS may be further updated in the 
future in order to get as close to this goal as possible. Setting modications include:
- Script is written so that it is easier to perform modifications, both simple and more advanced ones.
- Script is written so that it is easier to change or add more autonomouse filters, i.e. to include different search parameters.
- Script is written to allow manaual update/upgrade/autoremove, in case the VM-name is not matching the search-parameters.
- Script is written to allow easy change of colors/fonts and change messages.
- Toggle, on/off - Qubes current-testing repositories (for dom0/fedora/debian based systems respectively).
- Toggle, on/off - Autonomous -y accept of updates/upgrades (discouraged, but included).
  - Autoaccept of autoremove is on purpose not supported.
- Toggle, on/off - shutdown of LogVM upon script completion.
- Toggle, on/off - shutdown of sys-whonix upon script completion.
- Toggle, on/off - question-message providing options, whether to shutdown, restart, just shutodwn all VM's only, or do nothing, upon script completion.

<br />

### 7) Feature: Steps taken to make it easy to run UQUS, and in different ways.
 It makes no difference if you keybind the script, turn it into a clickable icon or menu item, or run it directly in 
your terminal, UQUS will always behave the same way. 
- This means, for example, you will always get the central output window, because
UQUS itself runs in the background, while the background script allocates a low-resource output window for information.
- You may optionally choose to disable the central log-window, however, it is useful to keep it enabled to stay informed.
- The easy access to enable/disable the central log-window, allowing the script to run the same way, whether by desktop shortcut, menu option, 
keybinded, executed manually in terminal, or even time based activation, provides the user with freedom to make own preferrences.

<br />

### 8) Feature: Quick and easy to stop the script gracefully.
The script is increasingly being made to support this goal, so that you retain maximum control of your update/upgrade process.
More work may be done in the future to enhance this capability further, for example to "pick up" where you left off, rather than
having to start the update/upgrade procress all over again from the beginning.

<br />

### 9) Limitation: Some minor UQUS VM-naming limitations to be aware of.
There is a different more simple script existing which part of UQUS's autonomous parts is also inspired by, which can run all 
templates despite of their given VM-names. The reason UQUS is inspired by this scripts full autonomous detection capability but UQUS remain minorly limited in its autonomous detection capaibity, in comparison, is because of additional commands being
executed, and also to allow the user to make changes in the script settings and freedom to personal prefferences.

**9.1. names like these will work autonomously:**
- Fedora-28
- stuff-fedora-28-apps
- stufffedora28apps
- Works similar for Debian/Whonix/CentOS).

**9.2. names like these won't work autonomously:**
- fed-28
- stuff-fed-28-apps
- stufffed28apps
- Any name without fedora (or Debian/Whonix/CentOS) in it.

If you do however happen to have specific TemplateVM's or StandaloneVM's which do not contain the name of the OS its
based on in the TemplateVM or standaloneVM's name, then you may either;
- Change the TemplateVM or standaloneVM name to containthe OS name it is based on.
- Manually create additional rules in the script (hardest of the three options, but not very difficult to do either).

<br />

### 10) Requirements and prerequisities.
- You must run UQUS in dom0, it will otherwise "currently" not work.
  - Thoughts are being put in to make it work in a VM, this feature "might" be introduced one day.
    - Speculation on whether to make Qubes-RPC changes automatically in the script, or instead alternatively make UQUS run in a VM (and change the Qubes-RPC's manually).
      - This is being considered as "trade-offs".
- For first-time users of scripts, you must first allow the script to be executeable. 
  - You may do this in dom0 with `chmod +x /path/to/script/uqus.bash`
- Ensure you have enough RAM to start your TemplateVM's, StandaloneVM's and optionally your LogVM.
  - Note: UQUS will **always** only start one TemplateVM/StandaloneVM at any one point in time, in a series of sequence.
  - But remember if you use the LogVM feature, it'll take up low-resources to run (i.e. some 300-400 RAM), but this VM 
  will only need to be run during the brief period UQUS is running, and can be optionally disabled as well.


<br />

### 11) More features are being pursued.
The above features should be ready soon. However some un-mentioned features are still being considered, and I lack time to start
working on them. Once the above features have been updated in UQUS, there might be some months before new features or fine-tuning updates emerge.

<br />

