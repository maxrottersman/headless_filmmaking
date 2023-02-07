$PSDefaultParameterValues = @{ 'out-file:encoding' = 'ascii' }

# Load Project Settings We Have in our settings.ini file. Explanation below
Get-Content ".\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0)-and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$Folder_Output_Videos = $h.Get_Item("Folder_Output_Videos")
$Output_Audio = $h.Get_Item("Output_Audio")
$Folder_Text_To_Speech = $h.Get_Item("Folder_Text_To_Speech")

# delete current file list and output vid
$FileName = "files_audio.txt"
if (Test-Path .\$FileName) {
   Remove-Item .\$FileName -verbose}


if (Test-Path .\$Output_Audio) {
   Remove-Item .\$Output_Audio -verbose}

# create our file list of videos for concatenation
$FileName = "files_audio.txt"
$captions = Import-Csv .\captions.txt -delimiter "|"

#
# First write text file with filenames for ffmpeg to concat
#
	ForEach ($caption in $captions){
	$filenumber = $($caption.filenumber)
	
	Write-host $filenumber
	
	echo "file `'${Folder_Text_To_Speech}duration_fix${filenumber}_tts.wav`'" >> .\$FileName
	
	}
#
# Concat!
#	
	
$cmd = "ffmpeg -f concat -safe 0 -i files_audio.txt -c copy -y ${Output_Audio}"

Write-host  $cmd
Invoke-Expression $cmd
	
#for testing
#break

	