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

CoordMode "ToolTip", "Screen"

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
    activeProcess := WinGetProcessName("ahk_id" activeID)
    activeArray := GetProcessWindowsArray("ahk_exe" activeProcess)

    if activeArray.Length = 1 {
        ; Only one window, nothing to switch to
        prevArray := []
        return
    }

    OutputDebug(ArrayToSortedString(activeArray) "`n")


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
        if !IsSet(lastIndex) && currentIndex != lastIndex {
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

    currentIndex := GetArrayIndex(activeArray, activeID)


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

        windowArray.Push(hwnd)
    }
    return windowArray
}

; Array utilities for this script
ArrayMatchSequence(arr1, arr2) {
    if !ArrayMatch(arr1, arr2)
        return false

    shiftedIndex := GetArrayIndex(arr2, arr1[1]) - 1

    for i, _ in arr1 {
        index2 := i + shiftedIndex
        if index2 > arr1.Length
            index2 -= arr1.Length

        if arr1[i] != arr2[index2]
            return false
    }
    return true
}

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

; For debugging
MakeListString(winArray) {
    foundProcessesArr := []
    for i, hwnd in winArray {
        processName := WinGetProcessName(hwnd)
        windowTitle := WinGetTitle(hwnd)
        windowClass := WinGetClass(hwnd)

        ; Example without the desktop number
        foundProcessesArr.Push({num: i, id: hwnd, exe: processName, wClass: windowClass, wTitle: windowTitle})
    }

    finalStr := "('0' for `"Show on all desktops`", '1' for Desktop 1)`n`n"

    for _, v in foundProcessesArr {
        finalStr .= v.desktopNum_ " | #:" v.num " | id:" v.id " | e:" v.exe " | c:" v.wClass " | t:" v.wTitle "`n"
    }

    return finalStr
}