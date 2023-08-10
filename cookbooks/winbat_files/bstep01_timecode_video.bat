setlocal
REM | change to current folder
pushd "%~dp0"

REM filename: "%~nx1"
REM target filename: %~n1_timecode%~x1

REM add timecode to video (-c:a copy remove audio -an)
ffmpeg -i video.mp4 -ss 00:00:00 -to 00:00:59 -vf  "drawtext=text='%%{pts\:hms}':fontfile=tahoma.ttf:fontsize=48:fontcolor=white:box=1:boxborderw=6:boxcolor=black@0.75:x=(w-text_w)/2:y=h-text_h-80" -an -y video_timecode.mp4

REM create external audio waveform video
ffmpeg -i extaudio.mp3 -ss 00:00:00 -to 00:00:59 -filter_complex "[0:a]showwaves=s=1920x1080:mode=line:rate=30,format=yuv420p[v]" -map "[v]" -map 0:a -r 30 -y "extaudio_waveform.mp4"

REM add timecode onto ext audio waveform
ffmpeg -i extaudio_waveform.mp4 -ss 00:00:00 -to 00:00:59 -vf  "drawtext=text='%%{pts\:hms}':fontfile=tahoma.ttf:fontsize=64:fontcolor=red:box=1:boxborderw=6:boxcolor=black@0.75:x=(w-text_w)/2:y=h-text_h-30" -c:a copy -y extaudio_waveform_timecode.mp4

REM superimpose vids
ffmpeg -i "video_timecode.mp4" -i "extaudio_waveform_timecode.mp4" -filter_complex  "[0:v]setpts=PTS-STARTPTS, scale=1080x720[top];[1:v]setpts=PTS-STARTPTS, scale=1280x720,format=yuva420p,colorchannelmixer=aa=0.5[bottom];[top][bottom]overlay=shortest=1" -y "video_to_find_sync_point.mp4"

rem pause

popd
