setlocal
REM | change to current folder
pushd "%~dp0"

@echo off

REM drag and drop file to extract audio from into variable "file_name"
set "file_name=%~1"

REM uses existing file name (stem), %~n1, and adds "_audio.wav" to end for
REM output file name
REM ffmpeg -i test1.mp4 -filter:a loudnorm test1_normalized.mp4
REM ffmpeg -i my_video.mp4 output_audio.wav
REM sox file -n stats
ffmpeg -i %file_name% %~n1_audio.wav

popd
