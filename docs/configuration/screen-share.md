
How to Share A Screen Across Qubes
==================================

> Warning:
> This guide involves opening up a TCP port between qubes. This is discouraged from the security standpoint and should only be used as a last resort, use sparingly.

## Terminology
PRESENTATION_QUBE is the Qube you want to view the screen from

CONTENT_QUBE is the Qube that has the window you want to share

## Setup The Shared Screen Server

Choose one of these sub-sections depending on whether you want to open a new screen (increased isolation), or use an existing monitor or screen.

### If You Want To Share a New Screen

In the Content Qube:

1. Install packages `sudo apt install xfwm4 tigervnc-standalone-server tigervnc-viewer` or `sudo dnf install xfwm4 tigervnc-server tigervnc`

2. Enter the password by executing `vncpasswd`

    1. You can generate secure enough passwords for this purpose using `openssl rand -base64 16 | tr -d '+/=' | head -c 8;echo`
    
    2. Enter one password for read/write (first password and verify prompt)

    3. Enter a different password for the view only password (second password and verify prompt)

3. Start the server `vncserver :1  -xstartup /usr/bin/xfwm4 -geometry 1920x1080 -localhost no`

4. View the shared screen `vncviewer -passwd ~/.vnc/passwd :1`

5. Open applications `DISPLAY=:1 xterm` where xterm can be any binary on your system

## If You Want To Share an Existing Monitor or Window

In the Content Qube:

1. Install packages `sudo apt install xfwm4 x11vnc x11-utils` or `sudo dnf install xfwm4 x11vnc xwininfo`

2. Enter the password by executing `x11vnc -storepasswd`

    1. You can generate secure enough passwords for this purpose using `openssl rand -base64 16 | tr -d '+/=' | head -c 8;echo`

3. Start the server 
    
    1. If you want to share a window `x11vnc -viewonly -rfbauth ~/.vnc/passwd -rfbport 5901 -clip 1920x1080+0+0`

        - Replace `1920x1080+0+0` with the resolution (e.g. `1920x1080`) and offset (e.g. `+0+0`) of the screen area you want to share. The coordinates 0,0 are in the top left, increasing down and to the right.

        - Use `xrandr --listactivemonitors` in Dom0 to get a list of all monitors and their offsets. That command returns in the form `W/_xH/_+X+Y`. For example to share DP-1, with xrandr output of ` 0: +DP-1 1920/510x1080/287+1280+0 DP-1`, 1920x1080+1280+0 would share just that screen.

        - `arandr` is a useful graphical tool to show where all the monitors are in relation to each other.

    2. If you want to share a monitor `x11vnc -viewonly -rfbauth ~/.vnc/passwd -rfbport 5901 -id pick`

        - This retrieves the numerical id of the next window you click on.

    3. If you want to share all the monitors use `x11vnc -viewonly -rfbauth ~/.vnc/passwd -rfbport 5901`

4. View the shared screen as specified in "View The Shared Screen"

5. Open applications like normal

## Qubes Connect TCP Service

These steps are a simpler version of [The Qubes Firewall](https://www.qubes-os.org/doc/firewall/#opening-a-single-tcp-port-to-other-network-isolated-qube). In dom0 execute these steps:

1. Edit /etc/qubes-rpc/policy/qubes.ConnectTCP 

2. Add the line: `<PRESENTATION_QUBE> @default ask,target=<CONTENT_QUBE>`

    - (recommended) By specifying `ask`, dom0 will ask each time a connection is attempted on that port

    - (not recommended) Rather than specifying `ask` you can use `allow` to allow all connections without a prompt, this leaves you unaware of new attempted connections.

3. After you are done sharing you screen, remove this line to prevent further unwanted connections

## View The Shared Screen

In the Presentation Qube:

1. Install package `sudo apt install -y tigervnc-viewer`

2. Bind TCP port using Qubes Connect TCP service `qvm-connect-tcp ::5901`

3. Start the VNC Viewer `vncviewer -Shared -ViewOnly -RemoteResize=0 -SendPrimary=0 -SendClipboard=0 -SetPrimary=0 127.0.0.1:5901`

4. Confirm that you want to connect to the Presentation Qube in the dom0 prompt

5. Enter password for the VNC server you created above

6. In your presentation software share the VNC viewer

## Present

In the Content Qube interact with the shared screen, the changes will be mirrored back to your Presentation Qube.

## Notes

- To reset the VNC password delete `~/.vnc/passwd` in the Content Qube

- The Content Qube does not need to have access to the internet