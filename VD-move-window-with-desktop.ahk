;FROM https://superuser.com/questions/1685845/moving-current-window-to-another-desktop-in-windows-11-using-shortcut-keys

;#SETUP START
#SingleInstance force
ListLines 0
SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.
KeyHistory 0
#WinActivateForce

ProcessSetPriority "H"

SetWinDelay -1
SetControlDelay -1

; Include the library
#Include ../VD.ahk/VD.ah2
; VD.init() ; COMMENT OUT `static dummyStatic1 := VD.init()` if you don't want to init at start of script

; You should WinHide invisible programs that have a window.
try {
    WinHide "Malwarebytes Tray Application"
} catch {
}
;#SETUP END

VD.createUntil(3) ; Create until we have at least 3 virtual desktops

return

^#+Left:: {
    currentDesktop := VD.getCurrentDesktopNum()
    totalDesktops := VD.getCount()

    ; Loop around to the last desktop if at the first one
    previousDesktop := (currentDesktop = 1) ? totalDesktops : currentDesktop - 1
    activeWindow := WinExist("A")
    VD.goToDesktopNum(previousDesktop)
    VD.MoveWindowToDesktopNum("ahk_id " activeWindow, previousDesktop)
    WinActivate("ahk_id " activeWindow) ; Once in a while it's not active
}

^#+Right:: {
    currentDesktop := VD.getCurrentDesktopNum()
    totalDesktops := VD.getCount()

    ; Loop around to the first desktop if at the last one
    nextDesktop := (currentDesktop = totalDesktops) ? 1 : currentDesktop + 1
    activeWindow := WinExist("A")
    VD.goToDesktopNum(nextDesktop)
    VD.MoveWindowToDesktopNum("ahk_id " activeWindow, nextDesktop)
    WinActivate("ahk_id " activeWindow)
}
