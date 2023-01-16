#
# Use Imagemagick to create text captions against transparents backgrounds (PNG files)
#
$captions = Import-Csv .\captions.txt -delimiter "|"

	ForEach ($caption in $captions){
	$filenumber = $($caption.filenumber)
	$captiontext = $($caption.captiontext)

	Write-host $filenumber $captiontext

	$cmd = "magick -size 800x1600 -background none -font Open-Sans-Bold -strokewidth 2  -stroke blue   -undercolor white -gravity center caption:`" $( $captiontext)`"  $( $filenumber)caption.png"

	#Write-host  $cmd
	Invoke-Expression $cmd
	#break
	}