Evaluating Qubes - Walkthrough
============================

Thinking about using qubes?  
This document is not about how to use qubes securely.  
This document is a walkthrough, about how to evaluate qubes in order to answer the question "is qubes for me"?

You should evaulate qubes on a scratch system using a blank hard drive. 
After evaluating, if you decide that qubes is right for you, you should then delete your evaulation installation from the hard disk and install qubes for real, this time actually caring about the security of your data.

Part 1 - Install Qubes
======================

- Find compatible hardware
  - select a system to install qubes on by using https://www.qubes-os.org/doc/system-requirements/ and https://www.qubes-os.org/hcl/
  - the primary compatibility issues as of 4.0 are:
    - that your CPU/motherboard has (working and enabled) IOMMU support (Installation instructions say that IOMMU 
    - the compatibility of your graphics card
    - and USB issues when using USB keyboards & mice.
  - Also, despite saying that you can run it in 4 Gigs, you'll want at least 8 Gigs to evaluate 4.0

- Install Qubes 4.0 on a blank hard drive
  - Follow the installation instructions at https://www.qubes-os.org/doc/installation-guide/
  - Allow the installer to create the default qubes for you


Part 2 - Use/Evaluate Qubes
===========================

Your top priority in evaluating qubes should be to get email operational.

Normally, in qubes you increase your security by dividing your work into differnt domains, domains which you give names like "work", or "personal", or "turn-based-stragey-games".  During this evaluation we'll create a qube called "eval-qube" which you can consider to be your "real computer" where you will store all your data during evaulation.  

 - Select the "Q icon" in the far upper left, then select "Create Qubes VM".
 - change the name to "eval-qube"
 - Color does not matter yet and can be changed later
 - Leave type as "Qube based on a template (AppVM)"
 - You need to choose a "template domain" that will run you applications.  You can choose either fedora-32 (which uses dnf) or debian-10 (which uses apt, apt-get, and apt-cache).  Choose the one you are most familiar with. (and remember which one you chose for later)
 - Leave networking at "default (sys-net)"
 - Click "OK"


Note: It would be nice to document a option for using thunderbird here, but as of 2021-05-12 the current version of thunderbird has broken compatibility with the qubes plugin

set up mutt:

- We decided earlier to store your data in the "eval-qube" domain, but in qubes you don't install your applications in the same domain as your data, so we will need to install mutt in the "template domain" that you selected earlier.  This may sound strange but there is a good reason for it (the reason is documented in the qubes documentation, and wont be repeated here).
- Start the terminal for the template you chose by selecting the upper left "Q icon" then "Template: debian-10" (or "Template: fedora-32") then "Terminal"
- wait for 30 seconds till the terminal pops up.
- install all the packages that you will need to use mutt.  They are listed in the doument https://github.com/ddevz/Contents/blob/master/docs/configuration/mutt.md
  - for example, if using debian: apt-get update; apt-get install mutt fetchmail procmail urlview  (expand this)
  - if using fedora, then: dnf mutt ??? (research this)
- after you have these things installed, then shut down the template VM

- next, add "mutt" to the menu
  - select the upper left "Q icon", then "Domain: eval-qube", then "qube settings"
  - go to "applications"
  - mutt should be in the left hand column.  select mutt then press the ">" button to move it to the right column.
  - press apply then ok.

- next set up mutt
- start a terminal by selecting the upper left "Q icon", then "Domain: eval-qube", then terminal"
- set up mutt via the instructions at https://github.com/ddevz/Contents/blob/master/docs/configuration/mutt.md (wrong link, use correct link) .  The important parts to get working first:
  1. you want to set it up so you are able to recieve email.  
    - This will depend on if you want to use pop, imap, or the gmail protocal (find out what the gmail protocal is) depending on what type of email server you have. for pop you'd want to set up fetchmail and procmail to get your mail.  for gmail you'd use sasl-something?  for imap youd... ???
  1. set up urlview - follow the instructions for configuring urlview listed at 
  1. use the .muttrc configurations
- Now start mutt by selecting the upper left "Q icon", then "Domain: eval-qube", then "mutt"
- wait 30 seconds or so for mutt to start
  - Now that you are running mutt, select each email one by one, and press enter on each email you want to view.  (you can press q to stop viewing a email)

We finally get to your first qubes feature: 
When you are viewing a email (I.E before you hit q) and that email has a link displayed on the screen, but you have no evidence that you should just blindly trust the link is safe, hit Ctrl-B.  It will display a list of all links in the email.  select the link you want, hit enter and it will open the link in a web browser with a red border around it.  It may take 30 seconds or so to load, but that is because this web browser is special as it's actually running in a seperate (disposable) virtual machine.  View the web page, and when you are done close the web browser.  When the web browser closes, the (disposable) virtual machine is destroyed, so even if it did comprimize the system running the web browser, that system (virtual machine) has been destroyed and the system with your email has not been comprimized.

Dealing with downloads in a disposable VM:
==========================================

Now open a link like that from mutt again, but this time once you get to firefox, download something.  Suppose that link was a location of a download, in  which case you should download that.  If it wasn't a link to a download then just browse around the internet until you find something to download and download it.

Click on the download icon in the upper right hand corner of the firefox window, then find your download, right click on it, and select "open containing folder"

You are now in a filebrowser, and can inspect the file.  You can view it if its a picture, you can unzip/untar it if its a zip or tar file. You are still in the disposable virtual machine so you wont hurt your email VM by unzipping it here.

If you are finished with the download you can close the browser and the file manager, which will cause the disposable virtual machine to be destroyed.  However, if after inspecting the file, you decide you need to keep a copy of a file, then before closing everything out you can right click in the file browser, select "copy to VM", select "work" as the target and click "OK". Then open another terminal on your system running mutt, and look in ~/QubesIncoming/disp{some number}/ for your file.

Webbrowsing without mutt
========================

You can run firefox in a disposable VM without launching it from mutt by selecting the upper left "Q icon", then "Disposable: debian-10 DVM" then "firefox".  Use the same procedure as above to evaluate downloads and to transfer files back to your "eval-qube".

Remember! This is a disposable VM, meaning that any bookmarks that you add will be lost after you close the VM!

Also, if you know what tor is, you can easily run torbrowser instead by selecting the upper left "Q icon", then "Disposable: whonix-ws-15-dvm" then selecting "tor browser"

Note: Eventually you will try to bookmark something in the disposable VM.  Naturally when you create a bookmark in a disposable VM and then destroy the VM, the next time you create a disposable VM your bookmark will be gone.  There is a solution for this called "split browser" this will not be part of the evaluation here, but know that a solution exists.  You can read about it here: https://github.com/rustybird/qubes-app-split-browser 


Configure your terminal to use cut and paste:
=============================================

Out of the box, qubes cut and paste works well with basically everything but terminals.  unfortunately mutt needs a terminal to display in.

Select some text on the terminal with your mouse, go to the "edit" menu and look at the "copy" option.  You will note that the keybinding to copy is is "Shift-Ctrl-C" instead of just "Ctrl-V". Why not "Ctrl-V"?  Because Ctrl-V might mean something in mutt, or in your editor, and the terminal does not want to interfere with the operation of the program running in the terminal.  

however, "Shift-Ctrl-C" is same keybinding that qubes uses for something, and they cant both use the keybinding and both be useable at the same time, so you'll need to change this.  So go to "Edit" menu and select "preferences", then go to "shortcuts".  go to "copy" and double click on where it says "Shift-Ctrl-C" then when it says "New accellerator" hit Super+Shift+C ("super" is the "windows key").
now go to "paste" and double click on where it says "Shift-Ctrl-V" then when it says "New accellerator" hit Super+Shift+V 

Note: it is largely unknown, and not displayed in the shortcut list, but terminals can *also* use Ctrl-Ins and Shift-Ins for cut and paste.  However reaching that far across the keyboard for such a unmemorable keybinding could make you give up on qubes, so we are fixing it here.

Using cut and paste in qubes:
=============================

Now go to mutt and open the link in firefox again, but this time instead of downloading something, browse the net and find a URL that we will imagine that we want to email to the person.  while viewing a email in mutt, press "r" to respond to that person.  hit enter twice to get through the "to" and "subject" fields.  Now we are going to cut and paste the URL we found in a disposable VM into a email in our eval-qube/"real computer".  In qubes instead of the sequence being Ctrl-C, Ctrl-V, the sequence is Ctrl-C, Ctrl-Shift-C, Ctrl-Shift-V, Ctrl-V.  This key sequence only takes a tiny fraction of a second more time to hit then Ctrl-C, Ctrl-V so the sequence works quite well.  So go to the firefox in the disposable VM, select the whole URL and press Ctrl-C, Ctrl-Shift-C, then go to the window with mutt in it and press Ctrl-Shift-V, but instead of hitting Ctrl-V, hit Super-Shift-C (remember "super" is the windows key).  (why? because your pasting in a terminal)


Running untrusted code:
=======================

Now a common situation:  You want to find a new application to sove some problem.  