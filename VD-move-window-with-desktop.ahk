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
;#SETUP END

VD.createUntil(3) ; Create until we have at least 3 virtual desktops

DEBUG_LOG := false ; true logs each switch to %TEMP%\VD-move-window.log

; Move active window to the previous/next desktop and follow it
^#+Left:: SwitchDesktop(-1, true)
^#+Right:: SwitchDesktop(1, true)

; Override the default Win+Ctrl+Left/Right to switch instantly (no animation)
^#Left:: SwitchDesktop(-1)
^#Right:: SwitchDesktop(1)

SwitchDesktop(direction, bringActiveWindow := false) {
    ; Finish this press before handling the next one, so fast presses queue up instead of interleaving
    Critical

    currentDesktop := VD.getCurrentDesktopNum()
    totalDesktops := VD.getCount()

    ; Loop around to the other end when going past the first/last desktop
    targetDesktop := Mod(currentDesktop - 1 + direction + totalDesktops, totalDesktops) + 1

    window := 0
    if bringActiveWindow {
        window := WinExist("A")
        ; The desktop and taskbar can't be moved
        try {
            if window && WinGetClass(window) ~= "^(Progman|WorkerW|Shell_TrayWnd)$"
                window := 0
        }
    }

    if window {
        ; Send the window ahead first, so it arrives as the active, topmost window on that desktop.
        ; Then switch without activating anything else there (eg another Sublime/Chrome window)
        MoveWindowQuietly(window, targetDesktop)
        VD.goToDesktopNum(targetDesktop, false)
        try WinActivate("ahk_id " window)
        ; Windows sometimes hands focus to another window on that desktop a moment after arriving
        SetTimer(() => KeepFocus(window, targetDesktop), -250)
    } else {
        VD.goToDesktopNum(targetDesktop)
    }
    DesktopOSD.Show(targetDesktop, totalDesktops)

    if DEBUG_LOG {
        DebugLog(Format("{} {:+d}: desk {} -> {} | carry 0x{:X} | now on desk {}, window on desk {}, active 0x{:X}"
            , bringActiveWindow ? "MOVE  " : "SWITCH", direction, currentDesktop, targetDesktop, window
            , VD.getCurrentDesktopNum(), window ? VD.getDesktopNumOfWindow("ahk_id " window) : "-", WinExist("A")))
        ; Check again a moment later, to catch Windows bouncing us to another desktop afterwards
        SetTimer(() => DebugLog(Format("   +400ms: now on desk {}, window on desk {}, active 0x{:X}"
            , VD.getCurrentDesktopNum(), window ? VD.getDesktopNumOfWindow("ahk_id " window) : "-", WinExist("A"))), -400)
    }
}

; VD.MoveWindowToDesktopNum activates the window underneath on the old desktop when moving the active window,
; and Windows then jumps back to that desktop. This moves it without touching focus.
MoveWindowQuietly(hwnd, desktopNum) {
    try {
        found := VD._tryGetValidWindow("ahk_id " hwnd)
        if found {
            VD._dll_MoveViewToDesktop(found[2], VD._GetDesktops_Obj().GetAt(desktopNum))
            return
        }
    }
    ; Fall back to the public method if VD's internals ever change
    try VD.MoveWindowToDesktopNum("ahk_id " hwnd, desktopNum)
}

KeepFocus(hwnd, desktopNum) {
    ; Only if we're still on that desktop (not if the user already moved on)
    if VD.getCurrentDesktopNum() != desktopNum || WinActive("ahk_id " hwnd)
        return
    if DEBUG_LOG
        DebugLog(Format("   focus was taken by 0x{:X}, taking it back", WinExist("A")))
    try WinActivate("ahk_id " hwnd)
}

DebugLog(msg) {
    FileAppend(FormatTime(, "HH:mm:ss") "." SubStr(A_MSec "00", 1, 3) " " msg "`n", A_Temp "\VD-move-window.log", "UTF-8")
}

; Briefly shows "current / total" in the top-right corner of the primary monitor
class DesktopOSD {
    static gui := 0
    static hideTimer := ObjBindMethod(this, "Hide")
    static duration := 1000     ; ms on screen
    static screenFraction := 0.07 ; text height as a fraction of the screen height

    static Show(desktopNum, totalDesktops) {
        ; Recreate each time so the overlay lands on the newly active desktop
        this.Hide()

        ; Size relative to the screen so it looks the same at any resolution or display scaling
        MonitorGetWorkArea(MonitorGetPrimary(), , &top, &right, &bottom)
        textPx := Round((bottom - top) * this.screenFraction)
        pad := Round(textPx * 0.4)

        g := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 -DPIScale") ; E0x20 = click-through
        g.BackColor := "202020"
        g.MarginX := pad
        g.MarginY := Round(pad / 4)
        g.SetFont("s" Round(textPx * 72 / A_ScreenDPI) " bold cWhite", "Segoe UI")
        g.AddText(, desktopNum " / " totalDesktops)
        g.Show("Hide AutoSize")
        g.GetPos(, , &w)
        WinSetTransparent(220, g)
        ; Rounded corners on Windows 11 (ignored on older versions)
        try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", g.Hwnd, "UInt", 33, "Int*", 2, "UInt", 4)
        g.Show("NoActivate x" (right - w - pad) " y" (top + pad))
        this.gui := g
        SetTimer(this.hideTimer, -this.duration)
    }

    static Hide() {
        if this.gui {
            this.gui.Destroy()
            this.gui := 0
        }
    }
}
