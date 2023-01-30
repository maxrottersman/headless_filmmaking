set /P "vidnum=Enter Video File Number: "
set /P "vidseconds=Length Secs (5,7,10,15 only): "
IF %vidseconds% EQU 5 Set "SS=05"
IF %vidseconds% EQU 7 Set "SS=07"
IF %vidseconds% EQU 10 Set "SS=10"
IF %vidseconds% EQU 15 Set "SS=15"

setlocal
REM | Set "vidnum=vidXX"

REM | change to current folder
pushd "%~dp0"
REM can't put exact vars in REM notes below or it errors
REM | params explain: https://ss64.com/nt/syntax-args.html
REM | % ~ dI  - expands to a drive letter only (of passed I)
REM | % ~ pI = expands to path only (of passed I)
REM | % ~ dp = expand drive letter then path only of I
REM | I = 0 or path+filename dropped onto this BAT
REM | pushd  % ~ dp0
echo Encoding 720p ... 
REM | %~n1  Expand %1 to a file Name without file extension or path
REM | %~x1  Expand %1 to a file eXtension only - .txt

ffmpeg -i "%~1" -ss 00:00:00 -to 00:00:%SS% -vf "fps=30,scale=720:1280" -c:v  libx264 -c:a aac -b:a 128k -y "vid%vidnum%.mp4"
popd
REM pause