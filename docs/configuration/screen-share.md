
How to Share A Screen Across Qubes
==================================

## Setup The Shared Screen Server

In the Qube you want to want to share a screen from (referred to the Content Qube) execute these commands:

1. Install packages `sudo apt install -y xfwm4 tigervnc-standalone-server tigervnc-viewer`

2. Start the server `vncserver :10  -xstartup /usr/bin/xfwm4 -geometry 1920x1080 -localhost no`

3. Enter passwords when prompted

    1. You can generate secure enough passwords for this purpose using `openssl rand -base64 16 | tr -d '+/=' | head -c 8;echo`
    
    2. Enter one password for read/write (first password and verify prompt)

    3. Enter a different password for the view only password (second password and verify prompt)

3. View the shared screen `xtigervncviewer -passwd /home/user/.vnc/passwd :10`

4. Open applications `DISPLAY=:10 xterm` where xterm can be any binary on your system

## Qubes Connect TCP Service

These steps are a simpler version of [The Qubes Firewall](https://www.qubes-os.org/doc/firewall/#opening-a-single-tcp-port-to-other-network-isolated-qube). In dom0 execute these steps:

1. Edit /etc/qubes-rpc/policy/qubes.ConnectTCP 

2. Add the line: `PRESENTATION-QUBE @default ask,target=CONTENT-QUBE`

    - Where PRESENTATION-QUBE is the Qube you want to view the screen from

    - Where CONTENT-QUBE is the Qube that has the window you want to share

## View The Shared Screen

In the Qube you want to view the shared screen from (referred to the Presentation Qube):

1. Install package `sudo apt install -y tigervnc-viewer`

2. Bind TCP port using Qubes Connect TCP service `qvm-connect-tcp ::5910`

3. Start the VNC Viewer `vncviewer -Shared -ViewOnly -RemoteResize=0 -SendPrimary=0 -SendClipboard=0 -SetPrimary=0 127.0.0.1:5910`

4. Confirm that you want to connect to the Presentation Qube in the dom0 prompt

5. Enter the view only password given during step 3 of Setup The Shared Screen Server

6. In your presentation software share the VNC viewer

## Present

In the Content Qube interact with the shared screen, the changes will be mirrored back to your Presentation Qube.

## Notes

- To reset the VNC password delete `/home/user/.vnc/passwd` in the Content Qube

- The Content Qube does not need to have access to the internet

- Opening up a TCP port between Qubes Should only be used as a last resort, use sparingly.

- After you are done, remove the line you added in `/etc/qubes-rpc/policy/qubes.ConnectTCP`
