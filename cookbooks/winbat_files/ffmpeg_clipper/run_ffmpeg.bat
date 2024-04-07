@echo off
echo Creating clip from 0:00:01.566 to 0:00:03.366
set /p "output_name=Enter the output filename (without .mp4): "
set "ffmpeg_cmd=ffmpeg -ss 0:00:01.566 -to 0:00:03.366 -i "C:\Max_Software\a_ffmpeg_dev\Headless_Filmmaking\cookbooks\winbat_files\ffmpeg_clipper\audience.mp4" -c:v libx264 -c:a aac -b:a 128k -y "%output_name%.mp4""
echo Running FFmpeg command:
echo %ffmpeg_cmd%
%ffmpeg_cmd%
pause
