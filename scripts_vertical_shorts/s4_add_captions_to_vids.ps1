
# Load captions
# works in prompt:
#Import-Csv .\captions.txt -delimiter "|" | select filenumber, captiontext

$captions = Import-Csv .\captions.txt -delimiter "|"

	ForEach ($caption in $captions){
	$filenumber = $($caption.filenumber)
	
	Write-host $filenumber

	#$cmd = "magick -size 800x1600 -background none -font Open-Sans-Bold -strokewidth 2  -stroke blue   -undercolor white -gravity center caption:`" $( $captiontext)`"  $( $filenumber)caption.png"
	
	$cmd = "ffmpeg -i $($filenumber)panned.mkv -loop 1 -i $($filenumber)caption.png -filter_complex `"[1:0] format=rgba,fade=in:st=0:d=3:alpha=1,fade=out:st=6:d=3:alpha=1 [ovr];[0:0][ovr] overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2`" -t 5 -y $($filenumber)addedcaption.mkv"

	Write-host  $cmd
	Invoke-Expression $cmd
	
	#for testing
	#break

	}