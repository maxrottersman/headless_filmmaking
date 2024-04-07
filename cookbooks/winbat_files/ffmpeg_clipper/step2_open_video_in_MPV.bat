@echo off
set "VideoFile=%~1"
start "" "C:\Max_Software\MPV_2024\mpv.exe" "--force-window=yes" "--geometry=800x600" "--keep-open=yes" "--script=copyTime.lua " %VideoFile%"