# Load Project Settings We Have in our settings.ini file. Explanation below
Get-Content ".\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0)-and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

# Config from settings.ini file
$Folder_Captions = $h.Get_Item("Folder_Captions")
$File_Captions_Graphics = $h.Get_Item("File_Captions_Graphics")
$File_Graphics = $h.Get_Item("File_Graphics")
$Folder_Graphics = $h.Get_Item("Folder_Graphics")

# Now load captions from file...
$captions = Import-Csv $Folder_Captions$File_Captions_Graphics -delimiter "|"
$idx = 1

	ForEach ($caption in $captions){
	$filename = $($caption.FILENAME)
	$cmd = "magick $( $filename) -resize 1080x  $Folder_Graphics$($idx)_forYT.jpg"
	
	Write-Host $cmd
	Invoke-Expression $cmd
	
	$idx += 1
	}



