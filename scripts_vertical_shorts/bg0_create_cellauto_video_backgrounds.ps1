
$captions = Import-Csv .\captions.txt -delimiter "|"
$output_videos = "output_videos\filter_cellauto\"
$idx = 1

# last 2 repeat first 2
$CellAuto = @("9", "18", "22", "26", "30", "41", "45", "50", "54", "60", "62", "73", "75", "77", "82", "86", "89")

	ForEach ($caption in $captions){
	$filenumber = $($caption.FILENUMBER)
	$lengthseconds = $($caption.LENGTHSECONDS)
	$captiontext = $($caption.CAPTIONTEXT)

	#Write-host $filenumber $captiontext
	
	$frames = ([int]$lengthseconds * 30)

		$cmd = "ffmpeg -f lavfi -i cellauto=rule=$($CellAuto[$idx]),scale=1080:1920 -frames:v $($frames) -r 30 -y $output_videos$($filenumber)panned.mkv"

	$idx += 1
	Write-host  $cmd
	Invoke-Expression $cmd
	#break
	}


