; Switch between open Windows of the same App (.exe)
; Similar to Command+` on MacOS
;
;


;#SETUP START
#SingleInstance force
ListLines 0
SendMode "Input" ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir A_ScriptDir ; Ensures a consistent starting directory.
#WinActivateForce

ProcessSetPriority "H"

SetWinDelay -1
SetControlDelay -1

DetectHiddenWindows False ; Prevents showing hidden windows from other desktops

return
; **** END INIT ****

; Alt + ` - Activate NEXT Window of the same App

!`:: {  ; forward
		SwitchToSameProcess()
	}

+!`:: {  ; reverse
		SwitchToSameProcess(true)
	}



SwitchToSameProcess(reverse := false) {
    global prevArray, lastIndex

	if !IsSet(prevArray)
        prevArray := []

    activeID := WinExist("A")
    if !activeID
        return
    try {
        activeProcess := WinGetProcessName("ahk_id " activeID)
    } catch { ; eg an elevated window we aren't allowed to inspect
        return
    }
    activeArray := GetProcessWindowsArray("ahk_exe " activeProcess)

    if !activeArray.Length || (activeArray.Length = 1 && activeArray[1] = activeID) {
        ; Only one window, nothing to switch to
        prevArray := []
        return
    }

    ; Maintain consistent forward and backward movement in the window list
	; Notes:
	; if you click a different window out of order, it will update the stack order to be new;
	; if you click around, but go back the the same window you started on, it doesn't know the
    ; order changed so it'll go with the previous order.  Can't just pick a new stack order with
    ; each tap of the tick because it won't keep consisten forward and backwards movement that way
    currentIndex := GetArrayIndex(prevArray, activeID)
    if ArrayMatch(prevArray, activeArray) {
        ; Update the array if the focused window has changed
		; Note: best way to detect change without implementing window focus events
        if IsSet(lastIndex) && currentIndex != lastIndex {
            prevArray := activeArray
        }
    } else {
        ; Different windows involved, update the array
        prevArray := activeArray
    }
    currentIndex := GetArrayIndex(prevArray, activeID)

    if !IsSet(lastIndex)
        lastIndex := currentIndex

    activeArray := prevArray ; since they match keep original cycling order

    ; The active window may not be in the list (eg a dialog), then forward goes to the most recent window
    currentIndex := GetArrayIndex(activeArray, activeID) || 0


    if (!reverse) { ; forward goes to most recent window
		nextIndex := currentIndex + 1
		if (nextIndex > activeArray.Length) {
			nextIndex := 1
		}
	} else { ; backwards goes to oldest window
		nextIndex := currentIndex - 1
		if (nextIndex < 1) {
			nextIndex := activeArray.Length
		}
	}


    lastIndex := nextIndex
    WinActivate("ahk_id " activeArray[nextIndex]) ; Activate next Window
}

GetProcessWindowsArray(search) { ; Return the list of windows as an array object easier to pass around
    windowArray := []
    for hwnd in WinGetList(search, , , "PopupHost") {
        if WinGetMinMax(hwnd) < 0
            continue
        if !IsAltTabWindow(hwnd)
            continue

        windowArray.Push(hwnd)
    }
    return windowArray
}

; Roughly the same rules Alt+Tab uses, so we skip the taskbar/desktop (both explorer.exe),
; tool windows, dialogs owned by another window, and cloaked windows
IsAltTabWindow(hwnd) {
    exStyle := WinGetExStyle(hwnd)
    if (exStyle & 0x80) && !(exStyle & 0x40000) ; WS_EX_TOOLWINDOW without WS_EX_APPWINDOW
        return false
    if DllCall("GetWindow", "Ptr", hwnd, "UInt", 4, "Ptr") && !(exStyle & 0x40000) ; owned window
        return false
    cloaked := 0
    DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 14, "UInt*", &cloaked, "UInt", 4)
    if cloaked
        return false
    return !(WinGetClass(hwnd) ~= "^(Progman|WorkerW|Shell_TrayWnd|Shell_SecondaryTrayWnd)$")
}

; Array utilities for this script
ArrayMatch(arr1, arr2) {
    return ArrayToSortedString(arr1) = ArrayToSortedString(arr2)
}

ArrayToSortedString(arr) {
    return Sort(ArrayToString(arr), "D,")
}
ArrayToString(arr) {
    arrString := ""
    for i,_ in arr
        arrString .= "," arr[i]
    arrString := Trim(arrString, ",")
    return arrString
}

GetArrayIndex(arr, item) {
    for i, v in arr {
        if v = item
            return i
    }
    return ""
}