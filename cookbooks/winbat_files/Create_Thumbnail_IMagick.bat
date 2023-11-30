@echo off
setlocal

REM \n will add line break
set "text=Roy\nKatz"
set "background_image=background_interview2.png"

REM create text of name interviewed
magick -size 800x600 xc:black -font "Cooper-Black" -pointsize 150 -gravity center -fill white -stroke red -strokewidth 2 -annotate +0+0 "%text%" LText.png

magick composite -gravity center -geometry -480-0 LText.png "%background_image%" step1_add_Ltext.png

magick composite -gravity center -geometry +480-0 portrait.jpg step1_add_Ltext.png step2_add_portrait.png

endlocal