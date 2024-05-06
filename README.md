# Library all updated to AHK 2.0

# Win11AutoHotKeyFixes
This is to resolve deficiencies of Win11 window management, specifically moving active window to next desktop and cascading/tiling windows.

The App Specific Switcher came about because I wanted to duplicate the MacOS functionality of Using command-backtick (⌘-\`) to toggle between windows.  That comes as close as I could get it, which works pretty well I think.


## Process
I started with wanting to move the active window to the next desktop.  This [stackoverflow had a few really good answers](https://superuser.com/questions/1685845/moving-current-window-to-another-desktop-in-windows-11-using-shortcut-keys) that built on each other.  Last user was nice enough to give a AHK how-to:


> 1.  Download and install  [AutoHotKey](https://www.autohotkey.com/)
> 2.  Clone the  [VD.ahk](https://github.com/FuPeiJiang/VD.ahk)  repository (it is an AutoHotkey library adding several script
> functions for managing virtual desktops)
> 3.  Inside the cloned directory, create a new file (arbitrary name, ending with  `.ahk`) and paste the content from  [@Lorenzo
> Morelli](https://superuser.com/users/1567243/lorenzo-morelli)'s
> [answer](https://superuser.com/a/1708146/1185399)  into it.
> 4.  Double-click the script to run it. The shortcuts (Win+Ctrl+Shift+→: Move current window to the next desktop;
> Win+Ctrl+Shift+←: Move current window to the previous desktop) should
> now work.
> 5.  To make sure the script runs on every Windows startup, create a shortcut to it and put it into the folder for your Startup programs.
> Open that folder by typing  `shell:startup`  in the window that pops
> up after you hit  Win  +  R.

For this repo, the VD.ah2 directory needs to be a sibling of the files you check out here.


After I did this, making a CascadeWindows or TileWindows script seemed like it might not be too hard after [finding this ancient post](https://www.autohotkey.com/board/topic/80580-how-to-programmatically-tile-cascade-windows/).
It needed lots of tweaking to get it working, but it works well with multiple desktops without messing up the windows on other desktops.

While looking to see if there was anything else useful to implement, I came across a poorly implemented application switcher with no reverse.  I really missed this functionality from MacOS, Command+`, so I implemented it as best I could without events to know if the focus order had changed.

## Usage

 - ### Cascading windows
 - Win + Alt + C:  Cascade all windows on desktop
 - Win + Alt + H:  Tile all windows on desktop horizontally
 - Win + Alt + V:  Tile all windows on desktop vertically
 - Add + Shift to any of the above: Will only Cascade/Tile matching executables (eg all chrome windows)
 - ### Moving windows
 - Win + Ctrl + Shift + Left:  Move active window to the left desktop and follow it
 - Win + Ctrl + Shift + Right: Move active window to the right and follow it
 - ### App Specific Switcher (Command+`)
 - Alt+`:  Switch to most recent non-focused window of same app
 - Alt+Shift+`:  Switch to oldest non-focused windows of same app

## Other
If someone has a better suggestion for the cascading windows shortcuts, feel free to suggest it and any other ideas you might have.

