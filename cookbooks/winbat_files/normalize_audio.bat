setlocal
REM | change to current folder
pushd "%~dp0"

@echo off

REM drag and drop file to extract audio from into variable "file_name"
set "file_name=%~1"

REM use existing file name (stem), %~n1, adds "_moramalized.wav" 
ffmpeg -i %file_name% -filter:a loudnorm %~n1_normalized.mp4

popd
