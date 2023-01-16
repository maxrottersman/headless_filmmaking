
$captions = Import-Csv .\captions.txt -delimiter "|"

	ForEach ($caption in $captions){
	$filenumber = $($caption.filenumber)
	$captiontext = $($caption.captiontext)

	Write-host $filenumber $captiontext

	$cmd = "ffmpeg -loop 1 -i $($filenumber).jpg -framerate 30 -vf crop=1080:1920:n*4:0 -frames:v 150 -y $($filenumber)panned.mkv"
	
	Write-host  $cmd
	Invoke-Expression $cmd
	#break
	}


