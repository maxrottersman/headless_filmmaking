# Load Project Settings We Have in our settings.ini file. Explanation below
Get-Content ".\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0)-and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

# Config from settings.ini file
$Folder_Captions = $h.Get_Item("Folder_Captions").Trim()
$File_Captions_Timings = $h.Get_Item("File_Captions_Timings").Trim()
$Folder_Text_To_Speech = $h.Get_Item("Folder_Text_To_Speech").Trim()

# Setup Object TEXT to SPEECH
Add-Type -AssemblyName System.speech


# Load text
$captions = Import-Csv $Folder_Captions$File_Captions_Timings -delimiter "|"
$idx = 1

	ForEach ($caption in $captions){
	$filenumber = ($caption.FILENUMBER).Trim()
	$captiontext = ($caption.CAPTIONTEXT).Trim()
	$lengthseconds = $($caption.LENGTHSECONDS)
	
	$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
	$speak.Rate   = 0  # -10 to 10; -10 is slowest, 10 is fastest
	
	Write-Host $filenumber
	#break
	
	#Write-Host $($PSScriptRoot)\${Folder_Text_To_Speech}(${filenumber})_tts.wav
	
	$CreateFile = "$($PSScriptRoot)\${Folder_Text_To_Speech}${filenumber}_tts.wav"
	$CreateFile_AddedDuration = "$($PSScriptRoot)\${Folder_Text_To_Speech}duration_fix${filenumber}_tts.wav"
	Write-Host $CreateFile
	
	$speak.SetOutputToWaveFile(${CreateFile})
	$speak.Speak($captiontext)
	$speak.Dispose()
	
	$duration = ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ${CreateFile}
	
	#calculate padding necessary to make proper length
	#$Add_Duration = [math]::[Double]${lengthseconds}-[math]::[Double]${duration}
	$Add_Duration = ${lengthseconds}-${duration}
	
	If ($Add_Duration > 0)
	{
	 ffmpeg -i ${CreateFile} -af "apad=pad_dur=${Add_Duration}" -y ${CreateFile_AddedDuration}
	}
	else
	{
	ffmpeg -i ${CreateFile} -y ${CreateFile_AddedDuration}
	}
	
	Write-Host $lengthseconds $duration ${Add_Duration}
	
	# test
	#break
	}

#$speak.Dispose()

#ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 1_tts.wav






