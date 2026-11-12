; Originally based on: https://autohotkey.com/board/topic/80580-how-to-programmatically-tile-cascade-windows/
;
; phazei: That version used the Windows CascadeWindows/TileWindows API. Turns out on Win11 those silently skip
;         some windows (no error, just ignored, even though they can be moved fine), and they size windows wrong
;         with display scaling (eg 3000px wide windows on a 2560px screen). So now we do the math ourselves and
;         move each window directly.

; tileOrCascade: 1 = tile, 2 = cascade
; windowHandles: array of HWNDs, in z-order (topmost first, like WinGetList returns)
; arrangeType:   tile: 0 = vertical (side by side), 1 = horizontal (stacked)  |  cascade: ignored, always keeps z-order
; clientArea:    [left, top, right, bottom] to arrange within, defaults to the primary monitor's work area
WinArrange(tileOrCascade := 1, windowHandles := [], arrangeType := 0x1, clientArea := []) {
    if !windowHandles.Length
        return 0

    if !clientArea.Length {
        MonitorGetWorkArea(MonitorGetPrimary(), &left, &top, &right, &bottom)
        clientArea := [left, top, right, bottom]
    }

    ; Maximized windows can't be moved, restore them first
    for hwnd in windowHandles {
        if WinGetMinMax(hwnd) = 1
            WinRestore(hwnd)
    }

    if (tileOrCascade = 1)
        return _TileWindows(windowHandles, arrangeType & 0x1, clientArea)
    return _CascadeWindows(windowHandles, clientArea)
}

_CascadeWindows(windows, area) {
    n := windows.Length
    areaW := area[3] - area[1]
    areaH := area[4] - area[2]

    ; Offset each window by about a title bar's height, but squeeze the steps together when there are
    ; lots of windows so they never shrink below half the area
    step := Round(26 * A_ScreenDPI / 96)
    if n > 1
        step := Min(step, Floor(Min(areaW, areaH) * 0.5 / (n - 1)))
    w := areaW - step * (n - 1)
    h := areaH - step * (n - 1)

    ; Bottom of the z-order goes top-left, topmost window ends up in front at the end of the stairs
    count := 0
    for i, hwnd in windows {
        pos := n - i
        count += _MoveWindowVisible(hwnd, area[1] + pos * step, area[2] + pos * step, w, h)
    }
    return count
}

_TileWindows(windows, horizontal, area) {
    n := windows.Length
    areaW := area[3] - area[1]
    areaH := area[4] - area[2]

    ; Up to 3 windows go in a single row/column, more than that becomes a grid
    lines := n <= 3 ? n : Ceil(Sqrt(n))

    count := 0
    i := 0
    loop lines {
        line := A_Index - 1
        ; Spread any leftover windows across the first lines
        inLine := Floor(n / lines) + (line < Mod(n, lines) ? 1 : 0)
        loop inLine {
            cell := A_Index - 1
            hwnd := windows[++i]
            if horizontal { ; rows stacked top to bottom
                rowH := areaH / lines
                cellW := areaW / inLine
                x := area[1] + cell * cellW, y := area[2] + line * rowH, w := cellW, h := rowH
            } else { ; columns side by side
                colW := areaW / lines
                cellH := areaH / inLine
                x := area[1] + line * colW, y := area[2] + cell * cellH, w := colW, h := cellH
            }
            count += _MoveWindowVisible(hwnd, Round(x), Round(y), Round(w), Round(h))
        }
    }
    return count
}

; Win10/11 windows have invisible resize borders, so position by the visible frame instead
; (otherwise tiled windows end up with gaps between them)
_MoveWindowVisible(hwnd, x, y, w, h) {
    try {
        WinGetPos(&wx, &wy, &ww, &wh, hwnd)
        frame := Buffer(16, 0)
        if DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 9, "Ptr", frame, "UInt", 16) = 0 {
            borderL := NumGet(frame, 0, "Int") - wx
            borderT := NumGet(frame, 4, "Int") - wy
            borderR := (wx + ww) - NumGet(frame, 8, "Int")
            borderB := (wy + wh) - NumGet(frame, 12, "Int")
            x -= borderL, y -= borderT, w += borderL + borderR, h += borderT + borderB
        }
        WinMove(x, y, w, h, hwnd)
        return 1
    }
    return 0
}
