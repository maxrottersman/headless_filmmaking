#
# Use Imagemagick to create text captions against transparents backgrounds (PNG files)
#
# colors snow2, 
#
# captions.txt (example)
# filenumber|captiontext
# 1|Let's Make An Analogy For the Ukraine War
# 2|Putin Parked Thousands of Ladas In Ukraine...
# 
$captions = Import-Csv .\captions.txt -delimiter "|"
$captions_folder = "captions\"
# https://www.educba.com/powershell-array-of-strings/
# An array of random colors for variety
$IMcolors = @("white","snow2","MediumOrchid1","SlateGray1","cyan1","coral","LightSlateBlue","goldenrod1","LawnGreen","DeepSkyBlue1","magenta4","white","snow2")
# $($IMcolors[0])
$idx = 1

# ROUNDED BOX AROUND ALL
#magick -size 300x300 -background none -gravity center xc:none -fill "#00000080" -draw "roundrectangle 0,0 299,299 15,15" -fill white caption:"This is the time for all good men to come to the aid of their country" -composite rounded_corners.png

	ForEach ($caption in $captions){
	$filenumber = $($caption.filenumber)
	$captiontext = $($caption.captiontext)

	Write-host $filenumber $captiontext

	# BLOCK STYLE
	#$cmd = "magick -size 800x1600 -background none -font Open-Sans-Bold -strokewidth 2  -stroke " + $IMcolors[$idx] + "   -undercolor " + $IMcolors[$idx] + " -gravity center `"caption: $( $captiontext)\ `"  $( $filenumber)caption.png"
	
	# ROUNDED CORNERS STYLE (doesn't work top box, not perfect
	# 80% of 1080x1920 = 864x1536, 70% 756x1344
	$cmd = "magick -size 864x1536 -background none -font Open-Sans-Bold -strokewidth 2  -stroke " + $($IMcolors[$idx]) + "   -undercolor " + $($IMcolors[$idx]) + " -gravity center `"caption: $( $captiontext)\ `" ``( `+clone -morphology dilate disk:12 ``) `+swap -composite $captions_folder$( $filenumber)caption.png"

#
	Write-host  $cmd
	Invoke-Expression $cmd
	#break
	$idx += 1
	}