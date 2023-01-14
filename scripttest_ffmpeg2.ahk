#Requires AutoHotkey v1.1.33

winTitle := "ahk_class CASCADIA_HOSTING_WINDOW_CLASS"

F3::                        ; F3 = Start capture
SetTitleMatchMode, 2
WinGetTitle, winTitle,,ffmpeg.exe
msgbox %winTitle%
Return

#If WinExist(winTitle)
F4::                        ; F4 = Stop capture
WinActivate
Send q
WinWaitClose
Run % out
Return
#If