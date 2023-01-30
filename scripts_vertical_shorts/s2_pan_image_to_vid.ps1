
$captions = Import-Csv .\captions.txt -delimiter "|"
$idx = 1

	ForEach ($caption in $captions){
	$filenumber = $($caption.filenumber)
	$captiontext = $($caption.captiontext)

	Write-host $filenumber $captiontext
	
	# RtoL
	#crop="1080:1920:(iw-1080)-(n*10):0"
	if ($idx % 2)
	{
	$cmd = "ffmpeg -loop 1 -i $($filenumber).jpg -framerate 30 -vf crop=`"1080:1920:(iw-1080)-(n*10):0`" -frames:v 150 -y $($filenumber)panned.mkv"
	}
	else
	{
	$cmd = "ffmpeg -loop 1 -i $($filenumber).jpg -framerate 30 -vf crop=`"1080:1920:n*8:0`" -frames:v 150 -y $($filenumber)panned.mkv"	
	}
	$idx += 1
	Write-host  $cmd
	Invoke-Expression $cmd
	#break
	}


