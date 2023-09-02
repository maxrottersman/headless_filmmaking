setlocal
pushd "%~dp0"

ffmpeg -i "%~nx1" -ss 00:00:00 -to 00:00:59 -filter_complex "[0:a]showwaves=s=1280x720:mode=line:rate=30,format=yuv420p[v]" -map "[v]" -map 0:a -r 30 -y "%~n1_waveform.mp4"

REM pause

popd


