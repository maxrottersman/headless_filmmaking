# Script to convert a list of files using ffmpeg and powershell. This example converts to .ogv files (theora/vorbis as video/audio codecs)
# Please note that, if you havent done so, you should set the execution policy of powershell in order to be able to run this script.
# The easiest way to run this script without messing to much with execution policies is to set it for a single powershell session:
# powershell.exe -ExecutionPolicy Unrestricted
# Check: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies

# AUTHOR: https://gist.github.com/sergiobd/95403ea3087373b661c3b72b59d75eb0

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


# OLD METHOD
#$filenames = "1","2", "3", "4", "5","6","7", "8", "9"
#$filepath = "C:\Max_Software\a_ffmpeg_dev\vertical_shorts_dev\wrestling\try1\"
#$extension = ".jpg"

#ForEach( $file in $filenames){

#Convert using ffmpeg
#  ffmpeg -loop 1 -i 1.jpg -framerate 30 -vf crop=1080:1920:n*4:0 -frames:v 150 -y out.mkv

#ffmpeg -loop 1 -i $filepath$file$extension -framerate 30 -vf crop=1080:1920:n*4:0 -frames:v 150 -y $filepath$file.mkv}

