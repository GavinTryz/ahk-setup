#Requires AutoHotkey v2.0
#SingleInstance Force

; ------------------------------------------------------------------------
; Media Controls

; Ctrl+Insert → Play/Pause
^Insert::Send "{Media_Play_Pause}"

; Ctrl+Home → Previous track
^Home::Send "{Media_Prev}"

; Ctrl+End → Next track
^End::Send "{Media_Next}"

; Ctrl+Page Up → Volume Up
^PgUp::Send "{Volume_Up}"

; Ctrl+Page Down → Volume Down
^PgDn::Send "{Volume_Down}"

; ------------------------------------------------------------------------
; Control Play/Pause via the volume knob on my wireless headset
; Volume Up->Down->Up->Down → Play/Pause

global sequence := []
global resetTimer := 5000  ; 5 seconds
global lastPressTime := 0

Volume_Up:: {
    global sequence, lastPressTime

    Hotkey "Volume_Up", "Off"  ; Temporarily disable hotkey
    Send "{Volume_Up}"         ; Send key without triggering itself
    Hotkey "Volume_Up", "On"   ; Re-enable hotkey

    if (sequence.Length = 0 || sequence[-1] = "Volume_Down") {
        sequence.Push("Volume_Up")
        lastPressTime := A_TickCount
        SetTimer(ResetSequence, -resetTimer)
    }
}

Volume_Down:: {
    global sequence, lastPressTime

    Hotkey "Volume_Down", "Off"  ; Temporarily disable hotkey
    Send "{Volume_Down}"         ; Send key without triggering itself
    Hotkey "Volume_Down", "On"   ; Re-enable hotkey

    if (sequence.Length > 0 && sequence[-1] = "Volume_Up") {
        sequence.Push("Volume_Down")
        lastPressTime := A_TickCount
        SetTimer(ResetSequence, -resetTimer)
    }

    if (sequence.Length = 4) {
        Send "{Media_Play_Pause}"
        sequence := []  ; Reset sequence
    }
}

ResetSequence() {
    global sequence
    sequence := []
}

; ------------------------------------------------------------------------
; Helper: Fullscreen window detection

; Variable to store if the window is fullscreen
global isFullscreen := false

CheckFullscreen() {
    global isFullscreen
    if WinActive("A") {
        WinGetPos(, , &width, &height, "A")
        if (width = A_ScreenWidth && height = A_ScreenHeight) {
            isFullscreen := true
        } else {
            isFullscreen := false
        }
    } else {
        isFullscreen := false
    }
}

; Attach the WM_SIZE message to all windows to detect size changes
SetTimer(CheckFullscreen, 100)

; ------------------------------------------------------------------------
; Block Left Windows button when Fullscreen

LWin:: {
    if isFullscreen
        return
    Send "{LWin}"
}

; ------------------------------------------------------------------------
; Mouse4 → Win+Tab (only if NOT fullscreen)

~XButton1:: {
    global isFullscreen
    if (!isFullscreen) {
        Send("#{Tab}")  ; # represents the Windows key
    }
}