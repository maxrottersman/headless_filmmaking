# Load Project Settings We Have in our settings.ini file. Explanation below
Get-Content ".\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0)-and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

# Config from settings.ini file
$Folder_Captions = $h.Get_Item("Folder_Captions")
$Words_To_Seconds = $h.Get_Item("Words_To_Seconds")

# Now load captions from file...
$captions = Import-Csv $Folder_Captions\captions.txt -delimiter "|"
$captions_timings_file = $Folder_Captions + "\captions_timings.txt" 



$Line_Number = 1
$lines = "FILENUMBER|LENGTHSECONDS|CAPTIONTEXT`n"

	ForEach ($caption in $captions){
	$textline = $($caption.TEXT)
	
	$wordCount = ($textline -split '\W+' | Measure-Object).Count / $Words_To_Seconds
	$Line_Seconds = [Math]::Ceiling($wordCount)
	
	$lines = $lines + $Line_Number.ToString() + "|" + $Line_Seconds.ToString() + "|" + $textline + "`n"
	Write-host $Line_Number.ToString() + "|" + $Line_Seconds.ToString() + "|" + $textline
	#Invoke-Expression $cmd
	
	#for testing
	#break
	$Line_Number += 1
	}
	
$lines | Out-File $captions_timings_file