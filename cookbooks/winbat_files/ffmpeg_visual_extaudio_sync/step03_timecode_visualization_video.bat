setlocal
pushd "%~dp0"

REM DUPLICATE OF step01 process
REM will need to put percent-sign in front of the percent sign (double it)
REM to escape it after text='

ffmpeg -i "%~nx1" -ss 00:00:00 -to 00:00:59 -vf  "drawtext=text='%%{pts\:hms}':fontfile=tahoma.ttf:fontsize=48:fontcolor=white:box=1:boxborderw=6:boxcolor=black@0.75:x=(w-text_w)/2:y=h-text_h-20" -c:a copy -y ""%~n1_timecode%~x1"

popd
