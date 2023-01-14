#Requires AutoHotkey v1.1.33
app      := "ffmpeg.exe"
vid      := "Elgato Facecam" ; Depends on your camera
codec    := "mjpeg"                ; Depends on your camera
cLine    := " -f dshow -video_size 1280x720 -rtbufsize 702000k -framerate 30 -i video=""" vid """"
          . " -r 30 -threads 4 -vcodec " codec " -crf 0 -preset ultrafast -f mpegts "
out      := A_ScriptDir "\video.mkv"
winTitle := "ahk_class CASCADIA_HOSTING_WINDOW_CLASS"

F3::                        ; F3 = Start capture
FileRecycle % out
Run % app cLine out
Return

#If WinExist(winTitle)
F4::                        ; F4 = Stop capture
WinActivate
Send q
WinWaitClose
Run % out
Return
#If