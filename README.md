**Library & Setup Instructions all updated to AHK 2.0** 

# Win11AutoHotKeyFixes
This is to resolve deficiencies of Win11 window management, specifically moving active window to next desktop and cascading/tiling windows.

The App Specific Switcher came about because I wanted to duplicate the MacOS functionality of Using command-backtick (⌘-\`) to toggle between windows.  That comes as close as I could get it, which works pretty well I think.

I started with wanting to move the active window to the next desktop.  This [stackoverflow had a few really good answers](https://superuser.com/questions/1685845/moving-current-window-to-another-desktop-in-windows-11-using-shortcut-keys) that built on each other.  Last user was nice enough to give [an AHK how-to](https://superuser.com/a/1728476):

After I did this, making a CascadeWindows or TileWindows script seemed like it might not be too hard after [finding this ancient post](https://www.autohotkey.com/board/topic/80580-how-to-programmatically-tile-cascade-windows/).
It needed lots of tweaking to get it working, but it works well with multiple desktops without messing up the windows on other desktops.

While looking to see if there was anything else useful to implement, I came across a poorly implemented application switcher with no reverse.  I really missed this functionality from MacOS, Command+`, so I implemented it as best I could without events to know if the focus order had changed.

## Overview 

[AutoHotKey](https://www.autohotkey.com/) is free, and is now at Version 2. 

Once AutoHotKey is installed, scripts can be placed anywhere on your system, and end in `.ahk` or `.ah2` for v2 scripts.  
Double click to execute them, and they will remain running until terminated via the AHK dash or system restart. 

The scripts in this library utilize FuPeiJiang's Virtual Desktop library **VD.ahk**, which is an AutoHotkey library what adds several script functions for managing virtual desktops.  You will need those scripts as well as the ones in this repo. 

Both script folders must be adjacent to each other, for example;

```
C:\
└── Scripts
    └── Ahk
        ├── VD.ahk
        └── Win11AutoHotKeyFixes
```

Here both `VD.ahk` ( FuPeiJiang's library ) and `Win11AutoHotKeyFixes` ( this library ) are *folders* containing their respective scripts. 

To enable the hotkeys you want, you'll enter the `Win11AutoHotKeyFixes` folder and run the AHK scripts you want;

- `VD-move-window-with-desktop.ahk`
- `VD-cascade.ahk`
- `AppSpecificTabSwitcher.ahk`

These can be simply double-clicked to execute.

*Details on what hotkeys each of these enable, and how to automatically start them with Windows, are below.*

## Setup Process

These instructions assume you have [GIT for Windows](https://git-scm.com/downloads/win) installed.  If not, you can use Github's ZIP download feature and manually setup the directories accordingly. 

1.  Download and install  [AutoHotKey v2.0](https://www.autohotkey.com/)

2. Setup a directory for scripts e.g. we'll use `c:\Scripts\Ahk` here. 

    a. Create the folder

    b. Open the folder in a terminal window.
    To do this you can navigate to the folder in Explorer, then right click in the file pane and choose **Open in Terminal** which will launch PowerShell in that folder. 

2.  Clone FuPeiJiang's Virtual Desktop library [VD.ahk](https://github.com/FuPeiJiang/VD.ahk) from Github. 
You need the [v2_port branch](https://github.com/FuPeiJiang/VD.ahk/tree/v2_port) specifically. 

```
git clone --branch v2_port https://github.com/FuPeiJiang/VD.ahk.git
```

3. Clone this repository. 

```
git clone https://github.com/phazei/Win11AutoHotKeyFixes.git
```

4. Verify your setup.  Your Scripts folder should now contain two subfolders named `VD.ahk` and `Win11AutoHotKeyFixes`, like this; 

```
C:\
└── Scripts
    └── Ahk
        ├── VD.ahk
        └── Win11AutoHotKeyFixes
```

## Running the Script

Navigate to the `Win11AutoHotKeyFixes` and double-click the scripts you want to execute. 

- `VD-move-window-with-desktop.ahk`
- `VD-cascade.ahk`
- `AppSpecificTabSwitcher.ahk`

### Troubleshooting 

If you get any errors when you run the script, the most likely causes are;

- You have downloaded AHK v1 accidentally instead of v2 
- Your two folders are not adjacent in the same dir, or you've renamed `VD.ahk` to something else 
- You've accidentally cloned the `main` branch of **VD.ahk** rather than the `v2_port` branch 

### Automatically Installing these at Windows Startup 

1. For each script you want to autostart with Windows, create a shortcut. 

2. Press `Win+R` and type `shell:startup` to see your Windows startup folder. 

3. Drag those shortcuts in. 




## Usage

Functionality is divided into 3 scripts- 

### Moving windows

*Run the `VD-move-window-with-desktop.ahk` script.*

 - `Win + Ctrl + Shift + Left`:  Move active window to the left desktop and follow it
 - `Win + Ctrl + Shift + Right`: Move active window to the right and follow it

### Cascading windows

*Run the `VD-cascade.ahk` script.*

 - `Win + Alt + C`:  Cascade all windows on desktop
 - `Win + Alt + H`:  Tile all windows on desktop horizontally
 - `Win + Alt + V`:  Tile all windows on desktop vertically
 - Add `+ Shift` to any of the above: Will only Cascade/Tile matching executables (eg all chrome windows)

### App Specific Switcher (Command+`)

*Run the `AppSpecificTabSwitcher.ahk` script.*

 - ``Alt + ` ``:  Switch to most recent non-focused window of same app
 - ``Alt + Shift + ` ``:  Switch to oldest non-focused windows of same app

## Other 

If someone has a better suggestion for the cascading windows shortcuts, feel free to suggest it and any other ideas you might have.

