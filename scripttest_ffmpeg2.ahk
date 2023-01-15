#Requires AutoHotkey v1.1.33

winTitle := "ahk_class CASCADIA_HOSTING_WINDOW_CLASS"

F3::                        ; F3 = Start capture
; example DllCall
DllCall("MessageBox","Uint",0,"Str","This Message is poped through DLLcall","Str","I typed that title","Uint","0x00000036L")
Return

#If WinExist(winTitle)
F4::                        ; F4 = Stop capture
WinActivate
Send q
WinWaitClose
Run % out
Return
#If