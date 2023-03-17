# Load Project Settings We Have in our settings.ini file. Explanation below
Get-Content ".\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0)-and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

# Config from settings.ini file
$Folder_Captions = $h.Get_Item("Folder_Captions").Trim()
$File_Captions_Timings = $h.Get_Item("File_Captions_Timings").Trim()
$Folder_Text_To_Speech = $h.Get_Item("Folder_Text_To_Speech").Trim()

# Google
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\Max_Software\google_api_key\secdb-263122-f8422e9388df.json"

# prompt for testing
#$dialogue = Read-Host -Prompt 'Dialogue text'
#$outputName = Read-Host -Prompt 'Output file name (.mp3 extension will be added automatically)'

# Load text
$captions = Import-Csv $Folder_Captions$File_Captions_Timings -delimiter "|"
$idx = 1

	ForEach ($caption in $captions){
	$filenumber = ($caption.FILENUMBER).Trim()
	$captiontext = ($caption.CAPTIONTEXT).Trim()
	$lengthseconds = $($caption.LENGTHSECONDS)
	$TTSLANG = $($caption.TTSLANG)
	$TTSVOICE = $($caption.TTSVOICE)
	# Speaking pitch, in the range [-20.0, 20.0]. 20 means increase 20 semitones from the original pitch. -20 means decrease 20 semitones from the original pitch.
	$TTSPITCH = $($caption.TTSPITCH)
	# Speaking rate/speed, in the range [0.25, 4.0]. 1.0 is the normal native speed supported by the specific voice. 2.0 is twice as fast, and 0.5 is half as fast. If unset(0.0), defaults to the native 1.0 speed. Any other values < 0.25 or > 4.0 will return an error.
	$TTSSPEED = $($caption.TTSSPEED)
	
	Write-Host $filenumber
	
	#break
	
	$CreateFile = "$($PSScriptRoot)\${Folder_Text_To_Speech}${filenumber}_tts.wav"
	
	if (Test-Path $CreateFile) 
	{Remove-Item $CreateFile}
	
	$cred = gcloud auth application-default print-access-token
	# en-US-News-K (to N)
	# en-US-Wavenet-A (to N)
	
	# |en-US-Neural2-J (male but not working, don't know why)
	# |en-US-Wavenet-J	  (male)
	# |en-US-Wavenet-H (female)
	# |en-GB-Wavenet-F (female)
	# en-GB
	# en-US
	
	# default
	If ($TTSLANG -eq $null){$TTSLANG="en-US"}
	If ($TTSVOICE -eq $null){$TTSVOICE="en-US-Wavenet-J"}
	If ($TTSPITCH -eq $null){$TTSPITCH="0"}
	If ($TTSSPEED -eq $null){$TTSSPEED="1"}
	
	Write-Host $TTSLANG $TTSVOICE $TTSPITCH $TTSSPEED
	
		# for testing
		#if ($false)
		if ($true)
		{
			
		$headers = @{ "Authorization" = "Bearer $cred" }
		@{input=@{text=$captiontext};voice=@{languageCode="$TTSLANG";name="$TTSVOICE"; ssmlGender="FEMALE"};audioConfig=@{audioEncoding="LINEAR16";pitch="$TTSPITCH";speaking_rate="$TTSSPEED";sample_rate_hertz="48000"}} | ConvertTo-Json -Compress | Out-File -FilePath request-temp.json
		
		Invoke-WebRequest `
		  -Method POST `
		  -Headers $headers `
		  -ContentType: "application/json; charset=utf-8" `
		  -InFile request-temp.json `
		  -Uri "https://texttospeech.googleapis.com/v1/text:synthesize" | Select-Object -Expand Content | Out-File -FilePath response.json

		$JSONContent = Get-Content -Path "response.json" | ConvertFrom-JSON -AsHashtable
		$JSONContent.Values | Out-File -FilePath audioContent.base64
		certutil -decode audioContent.base64 $CreateFile
		}
	
	#Write-Host $($PSScriptRoot)\${Folder_Text_To_Speech}(${filenumber})_tts.wav
	# test
	#if ($idx -eq 2){break}
	
	$idx += 1
	}






