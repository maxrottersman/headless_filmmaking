@echo off
setlocal enabledelayedexpansion

set "folder="

:get_folder
set /p "folder=Enter the folder path containing .mp4 files: "

if not exist "%folder%" (
    echo Folder does not exist. Please try again.
    goto get_folder
)

for %%F in ("%folder%\*.mp4") do (
    set "file=%%~nxF"
    set "duration="

    for /f "delims=" %%I in ('ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%%F"') do (
        set "duration=%%I"
    )

    if defined duration (
        echo !file! - Length: !duration! seconds
    ) else (
        echo !file! - Length: Unknown
    )
)

pause
endlocal

