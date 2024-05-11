@echo off
set /p link="Enter the YouTube video link: "
yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --merge-output-format mp4 %link%
