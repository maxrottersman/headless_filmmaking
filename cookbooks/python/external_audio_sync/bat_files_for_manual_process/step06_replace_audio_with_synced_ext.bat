setlocal
pushd "%~dp0"

REM replace audio in original video file with new audio file we created
REM that should sync up.  If not, change the duration of our audio leader file

ffmpeg -i video.mp4 -i extaudio_synced.wav -c:v copy -map 0:v:0 -map 1:a:0 -y  video_synced_extaudio.mp4