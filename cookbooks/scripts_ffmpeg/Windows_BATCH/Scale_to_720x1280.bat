
REM | change to current folder
pushd "%~dp0"
echo Encoding 720p ... 

ffmpeg -i "%~1" -vf "fps=30,scale=720:1280" -c:v  libx264 -c:a aac -b:a 128k -y "vid_720.mp4"
popd
REM pause