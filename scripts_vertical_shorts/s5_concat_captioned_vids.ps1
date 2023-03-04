$PSDefaultParameterValues = @{ 'out-file:encoding' = 'ascii' }

# Load Project Settings We Have in our settings.ini file. Explanation below
Get-Content ".\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0)-and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$Folder_Output_Videos = $h.Get_Item("Folder_Output_Videos")
$Folder_Captions = $h.Get_Item("Folder_Captions")
$File_Captions_Timings = $h.Get_Item("File_Captions_Timings").Trim()
$Output_Video = $h.Get_Item("Output_Video")

# delete current file list and output vid
$FileName = "files.txt"
if (Test-Path .\$FileName) {
   Remove-Item .\$FileName -verbose}


if (Test-Path .\$OutputFileName) {
   Remove-Item .\$OutputFileName -verbose}

# create our file list of videos for concatenation
$FileName = "files.txt"
$captions = Import-Csv $Folder_Captions$File_Captions_Timings -delimiter "|"
#
# First write text file with filenames for ffmpeg to concat
#
	ForEach ($caption in $captions){
	$filenumber = $($caption.filenumber)
	
	Write-host $filenumber
	
	echo "file `'$Folder_Output_Videos$($filenumber)addedcaption.mp4`'" >> .\$FileName
	
	}
#
# Concat!
#	
	
$cmd = "ffmpeg -f concat -safe 0 -i files.txt -c copy -y $Output_Video"

#Write-host  $cmd
Invoke-Expression $cmd
	
#for testing
#break

	