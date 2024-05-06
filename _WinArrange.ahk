; Original from: https://autohotkey.com/board/topic/80580-how-to-programmatically-tile-cascade-windows/

; phazei: I updated it to use non-deprecated calls.
;         Also, not sure if it's a Win11 thing or not, but the "size" param for aKids needed adjusting.
;         It might be because window id's in the array are 0x123abc vs the 0-1920 for the screen rectangle.
;         But I have no idea what that "fill" line is for other than being some bitwise thing

WinArrange(tileOrCascade := 1, windowHandles := [], arrangeType := 0x1, clientArea := [], mainWindow := 0x0) {
    ; Prepare the client area if provided
    areaPointer := clientArea ? BufferFromArray(clientArea, "Int") : 0

    ; Prepare the window handles
    windowsPointer := windowHandles ? BufferFromArray(windowHandles, "Ptr") : 0

    ; Call the respective DLL function based on tileOrCascade
    if (tileOrCascade = 1) {  ; Tile windows
        return DllCall("TileWindows", "Int", mainWindow, "UInt", arrangeType, "Ptr", areaPointer, "Int", windowHandles.Length, "Ptr", windowsPointer)
    } else {  ; Cascade windows
        if arrangeType != 4  ; If arrangeType is 4, windows will be cascaded in ZORDER
            arrangeType := 0
        return DllCall("CascadeWindows", "Int", mainWindow, "UInt", arrangeType, "Ptr", areaPointer, "Int", windowHandles.Length, "Ptr", windowsPointer)
    }
}

BufferFromArray(arr, type) {
    elemSize := type = "Int" ? 4 : A_PtrSize
    totalSize := arr.Length * elemSize
    buf := Buffer(totalSize)

    for i, val in arr {
        offset := (i - 1) * elemSize
        NumPut(type, val, buf, offset)
    }

    return buf
}