#Requires AutoHotkey v2.0.2
#SingleInstance Force

; ====================================================================================================
; Enhanced AutoHotkey Script with Updated Virtual Desktop Management
; Author: Envico801
; Last Updated: 02/12/2024
; Description: This script provides custom keyboard shortcuts, window management features,
;              and virtual desktop switching capabilities using PowerShell 7.
; ====================================================================================================

; ====================================================================================================
; Global Variables
; ====================================================================================================

global WinKeyEnabled := false  ; Tracks the state of the Windows key (enabled/disabled)
global PowerShellPath := "C:\Program Files\PowerShell\7\pwsh.exe"  ; Path to PowerShell 7

; Initialize global variables
global opacity := 248  ; Default opacity (about 78% - adjust as needed) -  (minimum 40/255 ≈ 16%)
global lastWindow := ""
global windowOpacities := Map()  ; Dictionary to store window opacities

; Initialize the layout state
global isRowsLayout := true
; Initialize the layout state
global isBspLayout := true
; Initialize a variable to track Bluetooth state
global isBluetoothOn := false
; Initialize a variable to track Wifi 0 state
global isWiFi0On := true
; Initialize a variable to track Wifi 1 state
global isWiFi1On := false


; Set up a timer to check for active window changes
; SetTimer(CheckActiveWindow, 200)  ; Check every 100ms

; ====================================================================================================
; Helper Functions
; ====================================================================================================

/**
 * Checks if the active window matches a specific application.
 * @param {string} app - The name of the application to check for.
 * @returns {boolean} True if the active window matches the specified application, false otherwise.
 */
IsActiveWindowMatch(app := "") {

    ; Check if there is an active window
    if !WinExist("A") {
        return false  ; No active window
    }

    activeWindow := WinGetTitle("A")  ; Use WinGetTitle to get the title of the active window

    switch app {
        case "X Server":
            return InStr(activeWindow, "VcXsrv") > 0
        case "Browser":
            return InStr(activeWindow, "Google Chrome") > 0
        case "Shell":
            return InStr(activeWindow, "PowerShell") > 0
        case "Ubuntu":
            return InStr(activeWindow, "tmux") > 0
        default:
            return false
    }
}

RunPowerShellCommand(command) {
    Run(PowerShellPath . ' -WindowStyle Hidden -Command "' . command . '"', , "Hide")
}

ReloadScript() {
    Reload()
}

RestartProcess(processName, processPath) {
    ; Close the process by name
    ProcessClose(processName)

    ; Wait until the process is fully closed or timeout occurs
    ;Loop {
        ;if !ProcessExist(processName)
            ;break
        ;Sleep(100)  ; Sleep for 100 ms to avoid high CPU usage
    ;}

    ; Reopen the process using PowerShell
    RunPowerShellCommand('Start-Process "' . processPath . '"')
}

Komorebic(cmd) {
    RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

; Function to check and manage window opacity
CheckActiveWindow() {
    global lastWindow
    global windowOpacities
    try {
        activeWin := WinGetID("A")
        if (activeWin != lastWindow) {
            lastWindow := activeWin
            ; Check if we've already set opacity for this window
            if (!windowOpacities.Has(activeWin)) {
                ; If not in dictionary, set default opacity and store it

                ;ToolTip("Opacity not set, applying opacity")
                ;SetTimer(() => ToolTip(), -1000)  ; Hide tooltip after 1 second
                SetWindowOpacity(opacity, activeWin)
                windowOpacities[activeWin] := opacity
            }
        }
    }
}

; Function to set window opacity
SetWindowOpacity(value, activeWin) {
    try {
        ;activeWin := WinGetID("A")
        if (activeWin) {
            ; Skip applying to certain system windows to prevent issues
            ;title := WinGetTitle(activeWin)
            ;process := WinGetProcessName(activeWin)

            ; Skip TaskBar, Start Menu, etc.
            ;if (process = "explorer.exe" && (title = "" || InStr(title, "Task Switching")))
            ;   return

            WinSetTransparent(value, activeWin)

            ; Show a tooltip with current opacity percentage
            ;percentage := Round(value / 255 * 100)
            ;ToolTip("Opacity: " percentage "%")
            ;SetTimer(() => ToolTip(), -1000)  ; Hide tooltip after 1 second
        }
    }
    catch Error as err {
        ;ToolTip("Error setting opacity: " err.Message)
        ;SetTimer(() => ToolTip(), -2000)
    }
}

; ====================================================================================================
; Hotkeys and Shortcuts
; ====================================================================================================

; Toggle Win key state
!`::
{
    global WinKeyEnabled  ; Explicitly use the global variable
    WinKeyEnabled := !WinKeyEnabled
    ToolTip "Windows key " (WinKeyEnabled ? "enabled" : "disabled")
    SetTimer () => ToolTip(), -1000
}

; Disable Win key when it's not enabled
#HotIf !WinKeyEnabled
    LWin::return
    RWin::return
#HotIf


#HotIf !(IsActiveWindowMatch("X Server") || IsActiveWindowMatch("Ubuntu"))
    ; Focus windows
    !h::
    {
      Komorebic("focus left")
      CheckActiveWindow()
    }
    !j::
    {
      Komorebic("focus down")
      CheckActiveWindow()
    }
    !k::
    {
      Komorebic("focus up")
      CheckActiveWindow()
    }
    !l::
    {
      Komorebic("focus right")
      CheckActiveWindow()
    }
    ; Move windows
    !+h::
    {
      Komorebic("move left")
      CheckActiveWindow()
    }
    !+j::
    {
      Komorebic("move down")
      CheckActiveWindow()
    }
    !+k::
    {
      Komorebic("move up")
      CheckActiveWindow()
    }
    !+l::
    {
      Komorebic("move right")
      CheckActiveWindow()
    }
#HotIf

; Custom shortcuts (excluding X Server windows)
#HotIf !IsActiveWindowMatch("X Server")
    !+q::Komorebic("close")
    !m::Komorebic("minimize")

    ![::
    {
      Komorebic("cycle-stack previous")
      CheckActiveWindow()
    }
    !]::
    {
      Komorebic("cycle-stack next")
      CheckActiveWindow()
    }
    ; Stack windows
    ;!Left::Komorebic("stack left")
    ;!Down::Komorebic("stack down")
    ;!Up::Komorebic("stack up")
    ;!Right::Komorebic("stack right")
    !w::
    {
      Komorebic("stack-all")
      CheckActiveWindow()
    }
    !+w::
    {
      Komorebic("unstack-all")
      CheckActiveWindow()
    }
    ;![::Komorebic("cycle-stack previous")
    ;!]::Komorebic("cycle-stack next")
    ;!+Tab::Komorebic("cycle-focus previous")
    ;!Tab::Komorebic("cycle-focus next")

    ; Resize
    !=::Komorebic("resize-axis horizontal increase")
    !-::Komorebic("resize-axis horizontal decrease")
    ;!+=::Komorebic("resize-axis vertical increase")
    ;!+_::Komorebic("resize-axis vertical decrease")

    ; Manipulate windows
    !t::
    {
      Komorebic("toggle-float")
      CheckActiveWindow()
    }
    !f::
    {
      Komorebic("toggle-monocle")
      CheckActiveWindow()
    }
    ;!i::
    ;{
    ;  Komorebic("restore-windows")
    ;  ;CheckActiveWindow()
    ;}
    !i::Komorebic("retile")
    !g::Komorebic("toggle-pause")
    ;!g::Komorebic("unmanage")

    ; Window manager options
    ;!^r::Komorebic("retile")
    ;!p::Komorebic("toggle-pause")

    ; Layouts
    ;!x::Komorebic("change-layout rows")
    ;!y::Komorebic("change-layout columns")

    ;!y::Komorebic("change-layout bsp")
    !y::
    {
      global isBspLayout
      if (isBspLayout)
      {
          Komorebic("change-layout columns")
          isBspLayout := false
      }
      else
      {
          Komorebic("change-layout bsp")
          isBspLayout := true
      }
    }

    !x::
    {
      global isRowsLayout

      if (isRowsLayout)
      {
          Komorebic("change-layout columns")
          isRowsLayout := false
      }
      else
      {
          Komorebic("change-layout rows")
          isRowsLayout := true
      }
    }


    ; Workspaces
    !1::
    {
      Komorebic("focus-workspace 0")
      CheckActiveWindow()
    }
    !2::
    {
      Komorebic("focus-workspace 1")
      CheckActiveWindow()
    }
    !3::
    {
      Komorebic("focus-workspace 2")
      CheckActiveWindow()
    }
    !4::
    {
      Komorebic("focus-workspace 3")
      CheckActiveWindow()
    }
    !5::
    {
      Komorebic("focus-workspace 4")
      CheckActiveWindow()
    }
    !6::
    {
      Komorebic("focus-workspace 5")
      CheckActiveWindow()
    }
    !7::
    {
      Komorebic("focus-workspace 6")
      CheckActiveWindow()
    }
    !8::
    {
      Komorebic("focus-workspace 7")
      CheckActiveWindow()
    }
    !9::
    {
      Komorebic("focus-workspace 8")
      CheckActiveWindow()
    }
    !0::
    {
      Komorebic("focus-workspace 9")
      CheckActiveWindow()
    }

    ; Move windows across workspaces
    !+1::Komorebic("send-to-workspace 0")
    !+2::Komorebic("send-to-workspace 1")
    !+3::Komorebic("send-to-workspace 2")
    !+4::Komorebic("send-to-workspace 3")
    !+5::Komorebic("send-to-workspace 4")
    !+6::Komorebic("send-to-workspace 5")
    !+7::Komorebic("send-to-workspace 6")
    !+8::Komorebic("send-to-workspace 7")
    !+9::Komorebic("send-to-workspace 8")
    !+0::Komorebic("send-to-workspace 9")

    !d::
    {
      Send "#+d"                ; Alt + D = Win + Shift + D (open Powertoys run)
      ;CheckActiveWindow()
    }
    !Enter::
    {
      RunPowerShellCommand("wt.exe") ; Alt + Enter = Open Windows Terminal
      CheckActiveWindow()
    }
    !e::
    {
      RunPowerShellCommand("explorer.exe")
      CheckActiveWindow()
    }
    !^b::ReloadScript()
    !^m::
    {
        ReloadScript()
        RunPowerShellCommand("komorebic stop && komorebic start --ahk")
    }
    !^n::
    {
        ReloadScript()
        RestartProcess("yasb.exe", "C:\Users\enzod\AppData\Local\Yasb\yasb.exe")
    }
#HotIf

!^p::
{
  Komorebic("cycle-workspace next")
  CheckActiveWindow()
}
!^u::
{
  Komorebic("cycle-workspace previous")
  CheckActiveWindow()
}
!+f::
{
  Komorebic("toggle-monocle")
  CheckActiveWindow()
}
;!^i::Komorebic("toggle-maximize")
!+[::
{
  Komorebic("cycle-stack previous")
  CheckActiveWindow()
}
!+]::
{
  Komorebic("cycle-stack next")
  CheckActiveWindow()
}
!^l::
{
  global isBluetoothOn
  ; Repeated command because otherwise it will not work with 1 key press (you will have to push the key 2 times for it to work correctly if it wasnt because of the repetition)
  if (isBluetoothOn)
  {
      ; If Bluetooth is currently on, turn it off
      RunPowerShellCommand("radiocontrol.exe Bluetooth on")
      Sleep(3000)  ; Sleep for 100 ms to avoid high CPU usage
      RunPowerShellCommand("radiocontrol.exe Bluetooth on")
      Sleep(3000)  ; Sleep for 100 ms to avoid high CPU usage
      RunPowerShellCommand("radiocontrol.exe Bluetooth on")
      isBluetoothOn := false
  }
  else
  {
      ; If Bluetooth is currently off, turn it on
      RunPowerShellCommand("radiocontrol.exe Bluetooth off")
      Sleep(3000)  ; Sleep for 100 ms to avoid high CPU usage
      RunPowerShellCommand("radiocontrol.exe Bluetooth off")
      Sleep(3000)  ; Sleep for 100 ms to avoid high CPU usage
      RunPowerShellCommand("radiocontrol.exe Bluetooth off")
      isBluetoothOn := true
  }
}
!^k::
{
  global isWiFi0On
  ; Repeated command because otherwise it will not work with 1 key press (you will have to push the key 2 times for it to work correctly if it wasnt because of the repetition)
  if (isWiFi0On)
  {
      ; If WiFi 0 is currently on, turn it off
      RunPowerShellCommand("radiocontrol.exe 0 on")
      Sleep(3000)  ; Sleep for 100 ms to avoid high CPU usage
      RunPowerShellCommand("radiocontrol.exe 0 on")
      Sleep(3000)  ; Sleep for 100 ms to avoid high CPU usage
      RunPowerShellCommand("radiocontrol.exe 0 on")
      isWiFi0On := false
  }
  else
  {
      ; If WiFi 0 is currently off, turn it on
      RunPowerShellCommand("radiocontrol.exe 0 off")
      Sleep(3000)  ; Sleep for 100 ms to avoid high CPU usage
      RunPowerShellCommand("radiocontrol.exe 0 off")
      Sleep(3000)  ; Sleep for 100 ms to avoid high CPU usage
      RunPowerShellCommand("radiocontrol.exe 0 off")
      isWiFi0On := true
  }
}
!^j::
{
  global isWiFi1On
  ; Repeated command because otherwise it will not work with 1 key press (you will have to push the key 2 times for it to work correctly if it wasnt because of the repetition)
  if (isWiFi1On)
  {
      ; If WiFi 1 is currently on, turn it off
      RunPowerShellCommand("radiocontrol.exe 1 on")
      Sleep(3000)  ; Sleep for 100 ms to avoid high CPU usage
      RunPowerShellCommand("radiocontrol.exe 1 on")
      Sleep(3000)  ; Sleep for 100 ms to avoid high CPU usage
      RunPowerShellCommand("radiocontrol.exe 1 on")
      isWiFi1On := false
  }
  else
  {
      ; If WiFi 1 is currently off, turn it on
      RunPowerShellCommand("radiocontrol.exe 1 off")
      Sleep(3000)  ; Sleep for 100 ms to avoid high CPU usage
      RunPowerShellCommand("radiocontrol.exe 1 off")
      Sleep(3000)  ; Sleep for 100 ms to avoid high CPU usage
      RunPowerShellCommand("radiocontrol.exe 1 off")
      isWiFi1On := true
  }
}

; Hotkeys to manually adjust opacity if needed
;^!Up::    ; Ctrl + Alt + Up Arrow
;{
;    global opacity
;    opacity := Min(opacity + 15, 255)
;    CheckActiveWindow()
;}

;^!Down::  ; Ctrl + Alt + Down Arrow
;{
;    global opacity
;    opacity := Max(opacity - 15, 40)  ; Minimum 40 to keep window visible
;    CheckActiveWindow()
;}

^!r::     ; Ctrl + Alt + R
{
    global windowOpacities
    windowOpacities := Map()
    activeWin := WinGetID("A")
    SetWindowOpacity(255, activeWin)
}

; Shell-specific shortcuts
#HotIf IsActiveWindowMatch("Shell")
    ^e::Send "{Right}"            ; Ctrl + E = Right arrow
    ^a::
    {
        Send "{Right}"
        Send "{Enter}"
    }
#HotIf

; Block all other Win key combinations when Win key is disabled
#HotIf !WinKeyEnabled
    #a::
    #b::
    #c::
    #d::
    #e::
    #f::
    #g::
    #h::
    #i::
    #j::
    #k::
    #l::
    #m::
    #n::
    #o::
    #p::
    #q::
    #r::
    #s::
    #t::
    #u::
    #v::
    #w::
    #x::
    #y::
    #z::return
#HotIf

; ====================================================================================================
; End of Script
; ====================================================================================================
