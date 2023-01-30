@echo off
pushd "%~dp0"
set /P "vidnum=Enter Capture File Number: "

ffmpeg -f gdigrab -show_region 1 -framerate 30 -ss 00:00:01 -to 00:00:10 -video_size 720x1280 -offset_x 2400 -offset_y 500 -i desktop -vf "colorkey=black,format=rgba" -c:v libvpx-vp9 -b:v 2M -y cap%vidnum%.webm  