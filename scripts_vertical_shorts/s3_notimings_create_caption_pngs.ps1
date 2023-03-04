# Load Project Settings We Have in our settings.ini file. Explanation below
Get-Content ".\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0)-and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

# Config from settings.ini file
$Folder_Captions = $h.Get_Item("Folder_Captions")
$File_Captions = $h.Get_Item("File_Captions")

$ProjectWidth = $h.Get_Item("ProjectWidth")
$CapHeight = $h.Get_Item("CapHeight")
$CapWidth = $h.Get_Item("CapWidth")
#$CaptionSizeAdjustment = $h.Get_Item("CaptionSizeAdjustment")
# Adjust size based on "shrink" factor in settings file
#$CapWidth = [math]::Round([int]$ProjectWidth *[decimal]$CaptionSizeAdjustment)
#$CapHeight = [math]::Round([int]$ProjectHeight *[decimal]$CaptionSizeAdjustment)

$captions = Import-Csv $Folder_Captions$File_Captions -delimit "|"

# An array of random colors for variety
# https://imagemagick.org/script/color.php
$IMcolors = @("DarkSlateGray1","goldenrod1","MistyRose1","MediumOrchid1","SlateGray1","cyan1","coral","LawnGreen","DeepSkyBlue1","magenta4","white","snow2","LawnGreen","DeepSkyBlue1","magenta4","white","snow2")
$idx = 1

# IF WANT ROUNDED BOX AROUND ALL
#magick -size 300x300 -background none -gravity center xc:none -fill "#00000080" -draw "roundrectangle 0,0 299,299 15,15" -fill white caption:"This is the time for all good men to come to the aid of their country" -composite rounded_corners.png

	ForEach ($caption in $captions){
	#$filenumber = $($caption.FILENUMBER)
	#$lengthseconds = $($caption.LENGTHSECONDS)
	$captiontext = $($caption.CAPTIONTEXT)

	Write-host $captiontext
	
	# loop through first 3 colors (backwards from list above)
	$iColor = $idx % 3

	# BLOCK STYLE
	#$cmd = "magick -size 800x1600 -background none -font Open-Sans-Bold -strokewidth 2  -stroke " + $IMcolors[$idx] + "   -undercolor " + $IMcolors[$idx] + " -gravity center `"caption: $( $captiontext)\ `"  $( $filenumber)caption.png"
	
	# ROUNDED CORNERS STYLE (doesn't work top box, not perfect
	# 80% of 1080x1920 = 864x1536, 70% 756x1344
	$cmd = "magick -size $($CapWidth)x$($CapHeight) -background none -font Open-Sans-Bold -strokewidth 2  -stroke " + $($IMcolors[$iColor]) + "   -undercolor " + $($IMcolors[$iColor]) + " -gravity center `"caption: $($captiontext)\ `" ``( `+clone -morphology dilate disk:12 ``) `+swap -composite $Folder_Captions$($idx)caption.png"

#
	Write-host  $cmd
	Invoke-Expression $cmd
	#break
	$idx += 1
	}