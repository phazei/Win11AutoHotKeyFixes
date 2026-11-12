;#SETUP START
; ^ = control
; # = win
; ! = alt
; + = shift

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
#Include ./_WinArrange.ahk

;#SETUP END

; VD.createUntil(3) ; Create until we have at least 3 virtual desktops

TILE         := 1                    ; for WinArrange Param 1
CASCADE      := 2                    ; for WinArrange Param 1
VERTICAL     := 0                    ; for WinArrange Param 3
HORIZONTAL   := 1                    ; for WinArrange Param 3
ZORDER       := 4                    ; for WinArrange Param 3
CA_MARGIN    := 50                   ; margin around cascade

return

; ^ = control
; # = win
; ! = alt
; + = shift

; Do it for all windows on the current desktop
!#V:: { ; TileWindowsVertically
	WinArrangeDesktop(TILE, VERTICAL)
}

!#H:: { ; TileWindowsHorizontally
	WinArrangeDesktop(TILE, HORIZONTAL)
}

!#C:: { ; CascadeWindows
	WinArrangeDesktop(CASCADE, ZORDER)
}

; Only do it for the same processes
+!#V:: { ; TileWindowsVertically
	WinArrangeDesktop(TILE, VERTICAL, true)
}

+!#H:: { ; TileWindowsHorizontally
	WinArrangeDesktop(TILE, HORIZONTAL, true)
}

+!#C:: { ; CascadeWindows
	WinArrangeDesktop(CASCADE, ZORDER, true)
}

WinArrangeDesktop(arrangeType, arrangeOption, byProcess := false) {
	windows := GetCurrentDesktopWindows(byProcess)

	if !windows.Length ; If no windows exist, it would default to every window on every desktop = bad
		return

	WinArrange(arrangeType, windows, arrangeOption, GetClientArea())

	if byProcess
		BringWindowsToFront(windows)
}

BringWindowsToFront(windows) {
	for i, hwnd in windows {
		; by going in reverse the order doesn't change each time
		WinMoveTop("ahk_id " windows[-i])
    }
}

; Visible (non-minimized) windows on the current desktop, in z-order (topmost first)
GetCurrentDesktopWindows(byProcess := false) {
    bak_DetectHiddenWindows := A_DetectHiddenWindows

    windows := []

    try {
        activeProcess := WinGetProcessName("A")
    } catch {
        activeProcess := ""
    }
    currentDeskNum := VD.getCurrentDesktopNum()

    ; Make sure to get all windows from all virtual desktops
    DetectHiddenWindows true
    allWindows := WinGetList()
    for hwnd in allWindows {
		try {
        windowProcess := WinGetProcessName(hwnd)
		} catch {
			windowProcess := "UnknownFailure"
		}
        if byProcess && windowProcess != activeProcess
            continue

        desktopNum := VD.getDesktopNumOfWindow(hwnd)
        if desktopNum != currentDeskNum
            continue  ; must be on same desktop

        minimized := WinGetMinMax(hwnd)
        if minimized < 0
            continue

		windows.Push(hwnd)
    }

    DetectHiddenWindows bak_DetectHiddenWindows  ; reset to original value

    return windows
}

GetClientArea() {
    MonitorGetWorkArea(MonitorGetPrimary(), &left, &top, &right, &bottom)
    return [(left + CA_MARGIN), (top + CA_MARGIN), (right - CA_MARGIN), (bottom - CA_MARGIN)]
}

; Bring all windows of the active app to the front (arrows for keyboards without a numpad)
+!#Up::
+!#NumpadAdd:: {
    windows := GetCurrentDesktopWindows(true)
    BringWindowsToFront(windows)
}

; Send all windows of the active app to the back
+!#Down::
+!#NumpadSub:: {
    windows := GetCurrentDesktopWindows(true)
    for hwnd in windows
        WinMoveBottom("ahk_id " hwnd)
}