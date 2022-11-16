; Original from: https://autohotkey.com/board/topic/80580-how-to-programmatically-tile-cascade-windows/

; phazei: I updated it to use non-deprecated calls.
;         Also, not sure if it's a Win11 thing or not, but the "size" param for aKids needed adjusting.
;         It might be because window id's in the array are 0x123abc vs the 0-1920 for the screen rectangle.
;         But I have no idea what that "fill" line is for other than being some bitwise thing



WinArrange( TC=1, aStr="", VH=0x1, Rect="", hWnd=0x0 )  {
    CreateArray( aRect, Rect, 4 )                  ; Create a RECT structure. Note: size must be 4, 8 breaks it
    If !Rect
        lpRect := 0                                ; determining whether lpRect is NULL
    Else
        lpRect := % &aRect                         ; or a pointer to the RECT Structure.

    cKids := CreateArray( aKids, aStr, 8 )         ; Create an Array of window handles. Note: size must be 8, 4 makes every other window work.
    If !aStr
        lpKids := 0                                ; determining whether lpKids is NULL
    Else
        lpKids := % &aKids                         ; or a pointer to the array of handles.

    If ( TC = 1 )                                  ; then the windows have to be Tiled
        Return DllCall("TileWindows",Int,hWnd,UInt,VH,UInt,lpRect,Int,cKids,Int,lpKids)
    Else {                                         ; the windows have to be Cascaded
        If VH != 4                                 ; If VH is 4, windows will be cascaded in ZORDER
            VH := 0
        Return DllCall("CascadeWindows",Int,hWnd,UInt,VH,UInt,lpRect,Int,cKids,Int,lpKids)
    }
}

CreateArray( ByRef Arr, aStr="", Size=4 ) {        ; complicated variant of InsertInteger()
    If !aStr                                       ; aStr will be a pipe delimited string of integer values.
		Return 0

    aStr := StrReplace(aStr, "|", "|", aFields, -1)   ; Count the no. of pipes
    aFields := aFields + 1                            ; no. of pipes, +1 results in no of fields.

    VarSetCapacity( Arr, ( aFields*Size ), 0 ) ; Initialise var length and zero fill it.

    Loop, Parse, aStr, |
    {
        Loop %Size% {
            ; Thanks to Laszlo
            test := (0 pOffset)
            testArr := &Arr
            destination := &Arr+(0 pOffset)+A_Index-1
            fill := A_LoopField >> 8*(A_Index-1) & 0xFF ;no idea why, if someone can explain, that'd be cool
            DllCall( "RtlFillMemory", UInt, destination, UInt,1, UChar, fill )
        }
        pOffset += %Size%
    }

    VarSetCapacity( Arr, -1 ) ; make sure it's not too big

    Return aFields
}
