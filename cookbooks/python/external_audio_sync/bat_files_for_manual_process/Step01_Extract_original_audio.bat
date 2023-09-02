setlocal
REM | change to current folder
pushd "%~dp0"

@echo off

REM drag and drop file to extract audio from into variable "file_name"
set "file_name=%~1"

REM Mono 16bit audio (voice) is generally all I need
REM uses existing file name (stem), %~n1, and adds "_audio.wav" to end for
REM output file name
ffmpeg -i %file_name% -vn -acodec pcm_s16le -ac 1 -ar 16000 %~n1_audio.wav

popd