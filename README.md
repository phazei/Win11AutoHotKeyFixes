**Library & Setup Instructions all updated to AHK 2.0**

# Win11AutoHotKeyFixes

Windows 11 window management is missing some pretty basic stuff, so these scripts fill in the gaps:

- **Move the active window to the next/previous desktop** (and follow it there)
- **Switch desktops instantly**, without the slow slide animation, and wrap around at the ends
- **Cascade or tile windows**, only on the current desktop, without messing up windows on your other desktops
- **Switch between windows of the same app**, like MacOS Command+\` (⌘-\`)

## Hotkeys at a glance

| Hotkey | What it does | Script |
| --- | --- | --- |
| `Win + Ctrl + Left / Right` | Switch to the previous/next desktop instantly | `VD-move-window-with-desktop.ahk` |
| `Win + Ctrl + Shift + Left / Right` | Move the active window to the previous/next desktop and follow it | `VD-move-window-with-desktop.ahk` |
| `Win + Alt + C` | Cascade all windows on the current desktop | `VD-cascade.ahk` |
| `Win + Alt + H` | Tile all windows on the current desktop horizontally | `VD-cascade.ahk` |
| `Win + Alt + V` | Tile all windows on the current desktop vertically | `VD-cascade.ahk` |
| `Win + Alt + Shift + C / H / V` | Same as above, but only windows of the active app (eg all Chrome windows) | `VD-cascade.ahk` |
| `Win + Alt + Shift + Numpad+` | Bring all windows of the active app to the front | `VD-cascade.ahk` |
| `Win + Alt + Shift + Numpad-` | Send all windows of the active app to the back | `VD-cascade.ahk` |
| ``Alt + ` `` | Switch to the most recent other window of the same app | `AppSpecificTabSwitcher.ahk` |
| ``Alt + Shift + ` `` | Switch to the oldest other window of the same app | `AppSpecificTabSwitcher.ahk` |

Run only the scripts you want, they're independent of each other.

## Setup

You'll need [AutoHotKey v2](https://www.autohotkey.com/) (free), plus FuPeiJiang's [VD.ahk](https://github.com/FuPeiJiang/VD.ahk) library for the virtual desktop stuff.

These instructions assume you have [Git for Windows](https://git-scm.com/downloads/win) installed. If not, you can use Github's ZIP download for both repos and set up the folders the same way.

1. Download and install [AutoHotKey v2](https://www.autohotkey.com/). Make sure it's **v2**, not v1.

2. Make a folder for your scripts, we'll use `C:\Scripts\Ahk` here. Open it in Explorer, right click in the file pane and choose **Open in Terminal**.

3. Clone the **v2_port branch** of VD.ahk (the default branch is the old AHK v1 version and won't work):

    ```
    git clone --branch v2_port https://github.com/FuPeiJiang/VD.ahk.git
    ```

4. Clone this repo:

    ```
    git clone https://github.com/phazei/Win11AutoHotKeyFixes.git
    ```

5. Your folder should now look like this. **Both folders need to sit side by side**, and `VD.ahk` must keep that exact name, because the scripts look for it at `..\VD.ahk\`:

    ```
    C:\
    └── Scripts
        └── Ahk
            ├── VD.ahk
            └── Win11AutoHotKeyFixes
    ```

6. Go into `Win11AutoHotKeyFixes` and double-click whichever scripts you want. They'll keep running until you close them from the AHK tray icon / dash, or restart.

## Start them automatically with Windows

1. Right click each script you want and choose **Show more options → Create shortcut**.
2. Press `Win + R`, type `shell:startup` and hit Enter to open your startup folder.
3. Move the shortcuts in there.

Or, from a PowerShell window in the `Win11AutoHotKeyFixes` folder, this does all three at once:

```powershell
$startup = [Environment]::GetFolderPath('Startup'); $sh = New-Object -ComObject WScript.Shell
foreach ($s in 'VD-move-window-with-desktop','VD-cascade','AppSpecificTabSwitcher') {
    $l = $sh.CreateShortcut("$startup\$s.lnk"); $l.TargetPath = "$PWD\$s.ahk"; $l.WorkingDirectory = "$PWD"; $l.Save()
}
```

## Troubleshooting

If you get errors when running a script, it's almost always one of these:

- You installed AHK v1 instead of v2
- The `VD.ahk` and `Win11AutoHotKeyFixes` folders aren't side by side, or `VD.ahk` got renamed
- You cloned the `main` branch of **VD.ahk** instead of `v2_port`

If a hotkey just doesn't do anything, check that the script is actually running (look for the green **H** icon in the tray). After a Windows update it's worth pulling the latest VD.ahk too, since it relies on undocumented Windows internals that occasionally change.

## Details

### Moving windows & switching desktops

*`VD-move-window-with-desktop.ahk`*

I started with wanting to move the active window to the next desktop. This [superuser question had a few really good answers](https://superuser.com/questions/1685845/moving-current-window-to-another-desktop-in-windows-11-using-shortcut-keys) that built on each other, and the last user was nice enough to give [an AHK how-to](https://superuser.com/a/1728476).

It turned out switching this way skips the Windows slide animation, which is way faster, so the script now takes over the regular `Win + Ctrl + Left / Right` too. Both versions wrap around, so going right from your last desktop takes you back to the first. Since there's no "wall" anymore, a little `2 / 3` indicator pops up in the top right corner for a second so you always know where you are. It scales with your screen size; if you want it bigger or smaller, change `screenFraction` in the script.

Note: on startup this script makes sure you have at least 3 desktops (`VD.createUntil(3)`). Change or remove that line if you'd like a different number.

### Cascading & tiling windows

*`VD-cascade.ahk`*

After the desktop stuff, making a CascadeWindows or TileWindows script seemed like it might not be too hard after [finding this ancient post](https://www.autohotkey.com/board/topic/80580-how-to-programmatically-tile-cascade-windows/). It needed lots of tweaking to get it working, but it works well with multiple desktops without messing up the windows on other desktops. Minimized windows are left alone, maximized ones get restored first, and everything is arranged on your primary monitor.

That post used the built-in Windows CascadeWindows/TileWindows functions, but on Win11 those silently skip some windows for no visible reason (and size them wrong with display scaling), so the arranging is done by the script itself now.

If someone has a better suggestion for the cascading shortcuts, feel free to suggest it.

### App Specific Switcher (Command+\`)

*`AppSpecificTabSwitcher.ahk`*

While looking to see if there was anything else useful to implement, I came across a poorly implemented application switcher with no reverse. I really missed this from MacOS, so I implemented it as best I could without having events to know if the focus order changed. It comes pretty close, and works pretty well I think.

It keeps a consistent order while you tap through, so forward and back always make sense. If you click over to a different window of that app in between, it picks up the new order next time.

## Other

Ideas and PRs welcome, open an issue if you think of anything else Windows should have had in the first place.
