REM set /P "vidnum=Enter Video File Number: "
REM IF %vidseconds% EQU 5 Set "SS=05"

setlocal
REM | change to current folder
pushd "%~dp0"

ffmpeg -i "%~1" -c:v libvpx-vp9 -vf colorkey=0x000000,format=rgba -auto-alt-ref 0 -y "%~1.webm"

popd
REM pause