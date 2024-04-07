@echo off
SET input=%~1
SET output=%~n1_720p.mp4

if "%input%"=="" (
    echo No file provided.
    echo Usage: Drag and drop a .webm file onto this script.
    pause
    exit /b
)

REM mjpeg
REM ffmpeg -i "%input%" -vf "scale=-1:720" -c:v mjpeg -q:v 3 "%output%"
REM "%ffmpeg_path%\ffmpeg.exe" -i "%input_file%" -c:v copy -c:a copy "%output_file%"


ffmpeg -i "%input%" -vf "scale=-1:720" -c:v mjpeg -q:v 3 -pix_fmt yuvj420p -movflags +faststart "%output%"
echo Conversion complete.
pause