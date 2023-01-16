$PSDefaultParameterValues = @{ 'out-file:encoding' = 'ascii' }

# delete current file list and output vid
$FileName = "files.txt"
if (Test-Path .\$FileName) {
   Remove-Item .\$FileName -verbose}

$OutputFileName = "output.mkv"
if (Test-Path .\$OutputFileName) {
   Remove-Item .\$OutputFileName -verbose}

# create our file list of videos for concatenation
$FileName = "files.txt"
$captions = Import-Csv .\captions.txt -delimiter "|"

#
# First write text file with filenames for ffmpeg to concat
#
	ForEach ($caption in $captions){
	$filenumber = $($caption.filenumber)
	
	Write-host $filenumber
	
	echo "file `'$($filenumber)addedcaption.mkv`'" >> .\$FileName
	
	}
#
# Concat!
#	
	
$cmd = "ffmpeg -f concat -safe 0 -i files.txt -c copy output.mkv"

#Write-host  $cmd
Invoke-Expression $cmd
	
#for testing
#break

	