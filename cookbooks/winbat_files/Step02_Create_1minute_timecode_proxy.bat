setlocal
REM | change to current folder
pushd "%~dp0"

@echo off
REM drag and drop file to background removed video

set "file_name=%~1"

REM add timecode to video (-c:a copy remove audio -an)
ffmpeg -i %file_name% -ss 00:00:00 -to 00:00:59 -r 30 -vf  "drawtext=text='%%{pts\:hms}':fontfile=tahoma.ttf:fontsize=48:fontcolor=white:box=1:boxborderw=6:boxcolor=black@0.75:x=(w-text_w)/2:y=h-text_h-40" -an -y %~n1_1minute_timecode%~x1

popd
