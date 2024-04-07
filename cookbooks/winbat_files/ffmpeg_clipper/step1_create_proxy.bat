@echo off
set "VidFilename=%~1"
set "target_file=%~dpn1_proxy.avi"

ffmpeg -i "%VidFilename%" -vf "scale=960:540" -vcodec mjpeg -qscale:v 31 -c:a aac -b:a 192k -y "%target_file%"