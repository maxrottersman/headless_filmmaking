pushd "%~dp0"

@echo off
set /p t_silence=Enter Silence in Seconds: 

REM ask user for time
REM then create WAV file for that duration in silence

ffmpeg -f lavfi -t %t_silence% -i anullsrc=cl=mono -y silence_to_sync_audio.wav

REM Concatenate our SILENCE FILE + EXTERNAL AUDIO FILE = NEW WAV FILES
ffmpeg -i "silence_to_sync_audio.wav" -i "extaudio.mp3" -filter_complex [0:0][1:0]concat=n=2:v=0:a=1[out] -map [out] -y "extaudio_synced.wav"

REM replace audio in original video file with new audio file we created
REM that should sync up.  If not, change the duration of our audio leader file
ffmpeg -i video.mp4 -i extaudio_synced.wav -c:v copy -map 0:v:0 -map 1:a:0 -y  video_synced_extaudio.mp4

popd
