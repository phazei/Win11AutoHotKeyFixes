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
#Include ./_WinArrange.ahk


;you should WinHide invisible programs that have a window.
;WinHide, % "Malwarebytes Tray Application"
;#SETUP END

;VD.createUntil(3) ;create until we have at least 3 VD

TILE         := 1                    ; for WinArrange Param 1
CASCADE      := 2                    ; for WinArrange Param 1
VERTICAL     := 0                    ; for WinArrange Param 3
HORIZONTAL   := 1                    ; for WinArrange Param 3
ZORDER       := 4                    ; for WinArrange Param 3
CLIENTAREA   := "50|50|1200|1000"    ; for WinArrange Param 4

return

;DO IT FOR ALL WINDOWS ON CURRENT DESKTOP

!#V:: ;TileWindowsVertically
	WinArrangeDesktop( TILE, VERTICAL )
return

!#H:: ;TileWindowsHorizontally
	WinArrangeDesktop( TILE, HORIZONTAL )
return

!#C:: ;CascadeWindows
	WinArrangeDesktop( CASCADE, ZORDER )
return


;ONLY DO IT FOR SAME PROCESSES

+!#V:: ;TileWindowsVertically
	WinArrangeDesktop( TILE, VERTICAL, true )
return

+!#H:: ;TileWindowsHorizontally
	WinArrangeDesktop( TILE, HORIZONTAL, true )
return

+!#C:: ;CascadeWindows
	WinArrangeDesktop( CASCADE, ZORDER, true )
return


WinArrangeDesktop(arrangeType, arrangeOption, byProcess := "") {
	windows := GetCurrentDesktopWindows(byProcess)
	clientArea := GetClientArea()

	if !windows ;if no windows exist it would default to every window on every desktop = bad
		return

	WinArrange( arrangeType, windows, arrangeOption, GetClientArea() )
}

GetCurrentDesktopWindows(byProcess) {
	bak_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows, off

	desktopWindows := []
	stringWindows := ""

	WinGet, activeProcess, ProcessName, A

	; Make sure to get all windows from all virtual desktops
	DetectHiddenWindows On
	WinGet, windows, List
	Loop %windows%
	{
		hwnd := windows%A_Index%
		desktopNum_ := VD.getDesktopNumOfWindow("ahk_id" hwnd)
		If (desktopNum_ = VD.getCurrentDesktopNum())
		{
			WinGet, windowProcess, ProcessName, % "ahk_id" hwnd
			if (byProcess AND windowProcess != activeProcess)
				continue

			desktopWindows.Push({id:hwnd})
			stringWindows := stringWindows "|" hwnd
		}
	}

	stringWindows := Trim(stringWindows, "|")

	DetectHiddenWindows % bak_DetectHiddenWindows

	return stringWindows

}

GetClientArea() {
	SysGet, CA, MonitorWorkArea, 1
	sArea := CALeft + 30 "|" CATop + 30 "|" CARight - 30 "|" CABottom - 15

	return sArea
}


/*
;In the future do something with all selected windows
;Todo: add/remove windows from a group and only cascade or tile them.

^#NumpadADD::
Loop, Parse, ARRAY, |
  WinActivate, ahk_id %A_LoopField%
Return

^#NumpadSub::
Loop, Parse, ARRAY, |
  WinMinimize, ahk_id %A_LoopField%
Return

ExitRoutine:
Loop, Parse, ARRAY, |
  WinClose, ahk_id %A_LoopField%
ExitApp
Return

*/