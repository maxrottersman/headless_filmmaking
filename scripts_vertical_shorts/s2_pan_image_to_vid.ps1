
$captions = Import-Csv .\captions.txt -delimiter "|"
$caption_folder = "captions\"
$jpgs_folder = "jpgs\"
$output_videos = "output_videos\"
$idx = 1

	ForEach ($caption in $captions){
	$filenumber = $($caption.FILENUMBER)
	$lengthseconds = $($caption.LENGTHSECONDS)
	$captiontext = $($caption.CAPTIONTEXT)

	Write-host $filenumber $captiontext
	
	$frames = ([int]$lengthseconds * 30)
		
	# RtoL
	#crop="1080:1920:(iw-1080)-(n*10):0"
	if ($idx % 2)
	{
	$cmd = "ffmpeg -loop 1 -i $jpgs_folder$($filenumber).jpg -framerate 30 -vf crop=`"1080:1920:(iw-1080)-(n*10):0`" -frames:v $($frames) -y $output_videos$($filenumber)panned.mkv"
	}
	else
	{
	$cmd = "ffmpeg -loop 1 -i $jpgs_folder$($filenumber).jpg -framerate 30 -vf crop=`"1080:1920:n*8:0`" -frames:v $($frames) -y $output_videos$($filenumber)panned.mkv"	
	}
	$idx += 1
	Write-host  $cmd
	Invoke-Expression $cmd
	#break
	}


