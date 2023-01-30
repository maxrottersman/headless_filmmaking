pushd "%~dp0"
set /P "vidnum=Enter Vid and Capture File Number: "
echo vid%vidnum%

ffmpeg -i vid%vidnum%.mp4 -c:v libvpx-vp9 -i cap%vidnum%.webm -filter_complex "[0:v][1:v]overlay" -y vid%vidnum%_captioned.mp4


