; Switch between open Windows of the same App (.exe)
; Similar to Command+` on MacOS
;
;


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

;#Include ../VD.ahk/VD.ahk

CoordMode, ToolTip, Screen

DetectHiddenWindows, off ; if this is on it will show hidden windows from other desktops

return
; **** END INIT ****



; Alt + ` -  Activate NEXT Window of same type (title checking) of the current APP
!`::
	switchToSameProcess()
return

+!`::
	switchToSameProcess(true)
return



SwitchToSameProcess(reverse := "") {
	global prevArray
	global lastIndex

	activeId := WinExist("A")
	ahk_idId := "ahk_id " activeID
	WinGet, ActiveProcess, ProcessName, %ahk_idId%
	ahk_exeProcess := "ahk_exe" ActiveProcess
	activeArray := GetProcessWindowsArray(ahk_exeProcess)

	;ToolTip % MakeListString(activeArray), 100, 250, 3
	;ToolTip % MakeListString(prevArray), 100, 375, 4

	if (activeArray.Length() = 1) {
		; nothing to switch to
		prevArray := "" ; clear arrays working with
		return
	}


	; so this mostly works to enable consistent forward and backward movment in a list.
	; if you click a different window out of order, it will update the stack order to be new;
	; if you click around, but go back the the same window you started on, it doesn't know the
    ; order changed so it'll go with the previous order.  Can't just pick a new stack order with
    ; each tap of the tick because it won't keep consisten forward and backwards movement that way
	currentIndex := GetArrayIndex(prevArray, activeId) ; get index of selected window
	if (ArrayMatch(prevArray, activeArray)) { ; another window was clicked so order could have changed
		if (lastIndex AND currentIndex != lastIndex) {
			; this is how we can tell the stack order changed because different window was focused than
            ; where this left off. no perfect way to do this without implementing window focus events.
			prevArray := activeArray ; new array so set prev to match it
		}
	} else {
	    ; different windows involved, must have changed
		prevArray := activeArray ; new array so set prev to match it
	}
	currentIndex := GetArrayIndex(prevArray, activeId)

	if (!lastIndex)
		lastIndex = currentIndex

	activeArray := prevArray ; they match, so keep order of original while cycling forward and back in it

	currentIndex := GetArrayIndex(activeArray, activeId) ; get index of selected window


	if (!reverse) { ; forward goes to most recent window
		nextIndex := currentIndex + 1
		if (nextIndex > activeArray.Length()) {
			nextIndex = 1
		}
	} else { ; backwards goes to oldest window
		nextIndex := currentIndex - 1
		if (nextIndex < 1) {
			nextIndex := activeArray.Length()
		}
	}

	; debugging
	;ToolTip % "nextIndex:" nextIndex , 100, 100, 1
	;ToolTip % MakeListString(activeArray), 100, 120, 2

	lastIndex := nextIndex
	WinActivate, % "ahk_id " activeArray[nextIndex]	; Activate next Window


}


GetProcessWindowsArray(search) { ; return the list of windows as an array object easier to pass around
	windowArray := []

	WinGet, listOfWindows, List, %search%, , , "PopupHost"
	Loop %listOfWindows% {
		hwnd := listOfWindows%A_Index%

		WinGet, minimized, MinMax, % "ahk_id" hwnd
		if (minimized < 0)
			continue

		windowArray.Push(hwnd)
	}

	return windowArray
}

; array utilities build for this

; Items need to be in same order, but can be shifted.
; eg)  [1,2,3,4] == [3,4,1,2]  &&  [1,2,3,4] != [2,1,3,4]  &&  [1,2,3,4] != [4,3,2,1]
; uhg, turns out the stack changes too much so this way won't work
ArrayMatchSequence(arr1, arr2) {
	; first make sure the array elements match
	if (!ArrayMatch(arr1, arr2))
		return false

	shiftedIndex := GetArrayIndex(arr2, arr1[1]) ; find out where the first item in arr1 is in arr2
	shiftedIndex := shiftedIndex - 1

	Loop % arr1.Length() {
		index2 := A_Index + shiftedIndex
		if (index2 > arr1.Length())
			index2 := index2 - arr1.Length()

		if (arr1[A_Index] != arr2[index2])
			return false
	}
	return true
}

ArrayMatch(arr1, arr2) { ; true if they have same elements
	arr1String := ArrayToSortedString(arr1)
	arr2String := ArrayToSortedString(arr2)
	return arr1String = arr2String
}
ArrayToSortedString(arr) {
	arrString := ""
	Loop % arr.Length() {
		arrString := arrString "," arr[A_Index]
	}
	Trim(arrString, ",")
	Sort arrString, D,
	return arrString
}
GetArrayIndex(arr, item) {
	index := ""
	Loop % arr.Length() {
		if (arr[A_Index] = item) {
			index := A_Index
			break
		}
	}
	return index
}


; for debugging

MakeListString(winArray) {

	foundProcessesArr := []

	Loop % winArray.Length() {
		hwnd := winArray[A_Index]
		ahk_idId := "ahk_id " hwnd
		;VD.getDesktopNumOfWindow will filter out invalid windows
		; desktopNum_ := VD.getDesktopNumOfWindow("ahk_id" hwnd)
		;If (desktopNum_ > -1) ;-1 for invalid window, 0 for "Show on all desktops", 1 for Desktop 1
		;{
			WinGet, exe, ProcessName, %ahk_idId%
			WinGetTitle, wTitle, %ahk_idId%
			WinGetClass, wClass, %ahk_idId%

			foundProcessesArr.Push({num:A_Index, id:hwnd, exe:exe, wClass:wClass, wTitle:wTitle, desktopNum_:desktopNum_})
		;}
	}


	finalStr := "('0' for ""Show on all desktops"", '1' for Desktop 1)`n`n"

	for unused, v_ in foundProcessesArr {
		finalStr .= v_.desktopNum_ " | #:" v_.num " | id:" v_.id " | e:" v_.exe " | c:" v_.wClass " | t:" v_.wTitle "`n"
	}

	;MsgBox % finalStr
	;ToolTip % finalStr, 100, 120, 2
	return finalStr

}