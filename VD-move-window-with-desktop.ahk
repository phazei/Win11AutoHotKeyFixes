;FROM https://superuser.com/questions/1685845/moving-current-window-to-another-desktop-in-windows-11-using-shortcut-keys

;#SETUP START
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
ListLines Off
SetBatchLines -1
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
#KeyHistory 0
#WinActivateForce

Process, Priority,, H

SetWinDelay -1
SetControlDelay -1

;include the library
#Include ../VD.ahk/VD.ahk
; VD.init() ;COMMENT OUT `static dummyStatic1 := VD.init()` if you don't want to init at start of script

;you should WinHide invisible programs that have a window.
WinHide, % "Malwarebytes Tray Application"
;#SETUP END

VD.createUntil(3) ;create until we have at least 3 VD

return

^#+Left::
    n := VD.getCurrentDesktopNum()
    if n = 1 ;at begining, can't go left
        Return

    n -= 1
    active := "ahk_id" WinExist("A")
    VD.MoveWindowToDesktopNum(active,n)
    VD.goToDesktopNum(n)
    WinActivate active ;once in a while it's not active
Return

^#+Right::
    n := VD.getCurrentDesktopNum()
    if n = % VD.getCount() ;at end, can't go right
        Return

    n += 1
    active := "ahk_id" WinExist("A")
    VD.MoveWindowToDesktopNum(active,n)
    VD.goToDesktopNum(n)
    WinActivate active
Return