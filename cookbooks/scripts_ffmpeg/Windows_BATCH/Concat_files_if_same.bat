@echo off
pushd "%~dp0"
ffmpeg -f concat -safe 0 -i files.txt -c copy -y final_output.mp4