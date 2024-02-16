@echo off
setlocal

REM \n will add line break
set "author=Khalid\nAlkhaja"
set "title=Gaza Pogrom-\nJewish Act \nof Survival?!"
set "background_image=storyreview.png"

REM create text of author
magick -size 800x600 xc:none -font "Cooper-Black" -pointsize 150 -gravity center -fill gray -stroke black -strokewidth 6 -annotate +0+0 "%author%" LText.png

REM create text of title
magick -size 800x800 xc:none -font "Cooper-Black" -pointsize 100 -gravity center -fill gray -stroke blue -strokewidth 4 -annotate +0+0 "%title%" RText.png

magick composite -gravity north -geometry -280-0 LText.png "%background_image%" step1_add_Ltext.png

magick composite -gravity south -geometry +480-100 RText.png step1_add_Ltext.png YT_thumbnail.jpg

endlocal