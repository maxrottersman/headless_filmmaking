@echo off
set /p t_silence=Enter Silence in Seconds: 

REM ask user for time
REM then create WAV file for that duration in silence

ffmpeg -f lavfi -t %t_silence% -i anullsrc=cl=mono -y silence_to_sync_audio.wav