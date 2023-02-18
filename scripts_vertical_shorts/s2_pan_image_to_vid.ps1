# Load Project Settings We Have in our settings.ini file. Explanation below
Get-Content ".\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0)-and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$captions = Import-Csv .\captions.txt -delimiter "|"
#$caption_folder = "captions\" # used later to overlay caption pngs
#$jpgs_folder = "jpgs\"

$jpgs_folder = $h.Get_Item("Folder_BackgroundImages")
$output_videos = $h.Get_Item("Folder_BackgroundVideos")
$idx = 1

	ForEach ($caption in $captions){
	$filenumber = $($caption.FILENUMBER)
	$lengthseconds = $($caption.LENGTHSECONDS)
	$captiontext = $($caption.CAPTIONTEXT)

	Write-host $filenumber $captiontext
	
	$frames = ([int]$lengthseconds * 30)
		
	# RtoL
	#crop="1080:1920:(iw-1080)-(n*10):0"
	# higher n, faster, lower n, slower
	if ($idx % 2)
	{
	$cmd = "ffmpeg -loop 1 -i $jpgs_folder$($filenumber).jpg -framerate 30 -vf crop=`"1080:1920:(iw-1080)-(n*2):0`" -frames:v $($frames) -y $output_videos$($filenumber)panned.mkv"
	}
	else
	{
	$cmd = "ffmpeg -loop 1 -i $jpgs_folder$($filenumber).jpg -framerate 30 -vf crop=`"1080:1920:n*1:0`" -frames:v $($frames) -y $output_videos$($filenumber)panned.mkv"	
	}
	$idx += 1
	Write-host  $cmd
	Invoke-Expression $cmd
	#break
	}


