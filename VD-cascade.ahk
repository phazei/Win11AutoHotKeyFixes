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


; You should WinHide invisible programs that have a window.
; WinHide, "Malwarebytes Tray Application"
;#SETUP END

; VD.createUntil(3) ; Create until we have at least 3 virtual desktops

TILE         := 1                    ; for WinArrange Param 1
CASCADE      := 2                    ; for WinArrange Param 1
VERTICAL     := 0                    ; for WinArrange Param 3
HORIZONTAL   := 1                    ; for WinArrange Param 3
ZORDER       := 4                    ; for WinArrange Param 3
CLIENTAREA   := [50,50,1200,1000]    ; for WinArrange Param 4
CA_MARGIN     := 50                   ; margin around cascade

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

;!#T:: ; CascadeWindows testing EVERYTHING
; DllCall("CascadeWindows", "UInt", 0, "Int", 4, "Int", 0, "Int", 0, "Int", 0)
;return

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

	if !windows ; If no windows exist, it would default to every window on every desktop = bad
		return

	WinArrange(arrangeType, windows, arrangeOption, GetClientArea())

	if byProcess
		BringWindowsToFront(windows)
}

BringWindowsToFront(windows) {
	OutputDebug("reverse" windows[-1] "   ")
	OutputDebug("forward" windows[1] "`n")
	for i, hwnd in windows {
		; by going in reverse the order doesn't change each time
		WinMoveTop("ahk_id " windows[-i])
    }
}

; This seems to also return minimized windows, but fortunately, the Dll call ignores minimized windows
GetCurrentDesktopWindows(byProcess := false) {
    bak_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows false

    windows := []
    stringWindows := ""

    activeProcess := WinGetProcessName("A")

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

        windowTitle := WinGetTitle(hwnd)
        desktopNum := VD.getDesktopNumOfWindow(hwnd)
		currentDeskNum := VD.getCurrentDesktopNum()
        if desktopNum != currentDeskNum
            continue  ; must be on same desktop

        minimized := WinGetMinMax(hwnd)
        if minimized < 0
            continue

		;windows.Push({id:hwnd, title:windowTitle, processName:windowProcess})
		windows.Push(hwnd)
    }

    DetectHiddenWindows bak_DetectHiddenWindows  ; reset to original value

    return windows
}

GetClientArea() {
    MonitorGetWorkArea(1, &left, &top, &right, &bottom)
    return [(left + CA_MARGIN), (top + CA_MARGIN), (right - CA_MARGIN), (bottom - CA_MARGIN)]
}

+!#NumpadAdd:: { ; bring window of specific process to front
    windows := GetCurrentDesktopWindows(true)
    BringWindowsToFront(windows)
}
+!#NumpadSub:: { ; move all windows of specific process to back
    windows := GetCurrentDesktopWindows(true)
    for hwnd in windows
        WinMoveBottom("ahk_id " hwnd)
}

/*
ExitRoutine:
Loop, Parse, ARRAY, |
  WinClose, ahk_id %A_LoopField%
ExitApp
Return
*/