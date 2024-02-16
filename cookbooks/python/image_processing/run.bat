@echo off
setlocal enabledelayedexpansion

set "title=Kim|Griest"
set "subtitle=Real Reason|the American Middle Class|is Disappearing"

python Create_thumbnail_PIL_CenterTitleSubtitle.py "%title%" "%subtitle%"