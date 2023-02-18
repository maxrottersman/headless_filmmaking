# Load Project Settings We Have in our settings.ini file. Explanation below
Get-Content ".\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0)-and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$Folder_Output_Videos = $h.Get_Item("Folder_Output_Videos")
$Folder_Captions = $h.Get_Item("Folder_Captions")
$Folder_BackgroundVideos = $h.Get_Item("Folder_BackgroundVideos")

# Now load captions from file...
$captions = Import-Csv .\captions.txt -delimiter "|"
$caption_folder = "captions\"
$jpgs_folder = "jpgs\"
$output_videos = "output_videos\"

	ForEach ($caption in $captions){
	$filenumber = $($caption.FILENUMBER)
	$lengthseconds = $($caption.LENGTHSECONDS)
	
	# Don't need here but used to create panned vids	
	#$frames = ([int]$lengthseconds * 30)
	
	Write-host $filenumber
	# Slow Fade in, Slow Fade after 6 seconds
	#$cmd = "ffmpeg -i $Folder_BackgroundVideos$($filenumber)panned.mkv -loop 1 -i $caption_folder$($filenumber)caption.png -filter_complex `"[1:0] format=rgba,fade=in:st=0:d=3:alpha=1,fade=out:st=6:d=3:alpha=1 [ovr];[0:0][ovr] overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2`" -t $($lengthseconds) -y $Folder_Output_Videos$($filenumber)addedcaption.mkv"
	
	#Fast Fade In, NO FADE OUT
	$cmd = "ffmpeg -i $Folder_BackgroundVideos$($filenumber)panned.mkv -loop 1 -i $caption_folder$($filenumber)caption.png -filter_complex `"[1:0] format=rgba,fade=in:st=0:d=2:alpha=1:alpha=1 [ovr];[0:0][ovr] overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2`" -t $($lengthseconds) -y $Folder_Output_Videos$($filenumber)addedcaption.mkv"

	Write-host  $cmd
	Invoke-Expression $cmd
	
	#for testing
	#break

	}