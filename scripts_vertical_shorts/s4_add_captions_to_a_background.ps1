# Load Project Settings We Have in our settings.ini file. Explanation below
Get-Content ".\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0)-and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$Folder_Output_Videos = $h.Get_Item("Folder_Output_Videos")
$Folder_Captions = $h.Get_Item("Folder_Captions")
$File_Captions_Timings = $h.Get_Item("File_Captions_Timings").Trim()
$File_Background = $h.Get_Item("File_Background")

# Now load captions from file...
$captions = Import-Csv $Folder_Captions$File_Captions_Timings -delimiter "|"
$caption_folder = "captions\"
$jpgs_folder = "jpgs\"
$output_videos = "output_videos\"

	ForEach ($caption in $captions){
	$filenumber = $($caption.FILENUMBER)
	$lengthseconds = $($caption.LENGTHSECONDS)
	$captiontext = $($caption.CAPTIONTEXT)
	
	# Don't need here but used to create panned vids	
	#$frames = ([int]$lengthseconds * 30)
	
	
	# Won't fade in -> ,fade=in:st=0:d=02:alpha=1:alpha=1
	# ffmpeg -loop 1 -i backgrounds\bg_yellow.jpg -i Text_to_Speech\2_tts.mp3 -i captions\2caption.png -filter_complex "[2:v] format=rgba[ovr];[0:v][ovr] overlay=90:1300" -c:v libx264 -c:a copy -pix_fmt yuv420p -r 30 -shortest -y out.mp4
	
	Write-host $filenumber
	# Slow Fade in, Slow Fade after 6 seconds
	#$cmd = "ffmpeg -i $Folder_BackgroundVideos$($filenumber)panned.mkv -loop 1 -i $caption_folder$($filenumber)caption.png -filter_complex `"[1:0] format=rgba,fade=in:st=0:d=3:alpha=1,fade=out:st=6:d=3:alpha=1 [ovr];[0:0][ovr] overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2`" -t $($lengthseconds) -y $Folder_Output_Videos$($filenumber)addedcaption.mkv"
	
	#Fast Fade In, NO FADE OUT
	#$cmd = "ffmpeg -i $Folder_BackgroundVideos$($filenumber)panned.mkv -loop 1 -i $caption_folder$($filenumber)caption.png -filter_complex `"[1:0] format=rgba,fade=in:st=0:d=02:alpha=1:alpha=1 [ovr];[0:0][ovr] overlay=50:1200`" -t $($lengthseconds) -y $Folder_Output_Videos$($filenumber)addedcaption.mkv"
	Write-Host $captiontext.Length 
	if ($captiontext.Length -gt 25)
	{
	$cmd = "ffmpeg -loop 1 -i $File_Background -i Text_to_Speech\$($filenumber)_tts.wav -i $caption_folder$($filenumber)caption.png -filter_complex `"[2:v] format=rgba [ovr];[0:v][ovr] overlay=90:1300`" -c:a aac -b:a 128k -c:v libx264 -pix_fmt yuv420p -shortest -r 30 -y $Folder_Output_Videos$($filenumber)addedcaption.mp4"
	}
	else
	{
		$cmd = "ffmpeg -loop 1 -i $File_Background -i Text_to_Speech\$($filenumber)_tts.wav -i $caption_folder$($filenumber)caption.png -filter_complex `"[2:v] format=rgba [ovr];[0:v][ovr] overlay=90:1300`" -c:a aac -b:a 128k -c:v libx264 -pix_fmt yuv420p -t 2 -r 30 -y $Folder_Output_Videos$($filenumber)addedcaption.mp4"
	}
	

	Write-host  $cmd
	Invoke-Expression $cmd
	
	#for testing
	#break

	}