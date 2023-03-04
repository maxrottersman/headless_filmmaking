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
	
	Write-Host $filenumber
	#break
	
	$CreateFile = "$($PSScriptRoot)\${Folder_Text_To_Speech}${filenumber}_tts.wav"
	
	if ($CreateFile) {
   Remove-Item $CreateFile}
	
	$cred = gcloud auth application-default print-access-token
	# en-US-News-K (to N)
	# en-US-Wavenet-A (to N)
	
	$headers = @{ "Authorization" = "Bearer $cred" }
	@{input=@{text=$captiontext};voice=@{languageCode="en-US";name="en-US-Wavenet-A"; ssmlGender="MALE"};audioConfig=@{audioEncoding="LINEAR16"}} | ConvertTo-Json -Compress | Out-File -FilePath request-temp.json

	Invoke-WebRequest `
	  -Method POST `
	  -Headers $headers `
	  -ContentType: "application/json; charset=utf-8" `
	  -InFile request-temp.json `
	  -Uri "https://texttospeech.googleapis.com/v1/text:synthesize" | Select-Object -Expand Content | Out-File -FilePath response.json

	$JSONContent = Get-Content -Path "response.json" | ConvertFrom-JSON -AsHashtable
	$JSONContent.Values | Out-File -FilePath audioContent.base64
	certutil -decode audioContent.base64 $CreateFile
	
	#Write-Host $($PSScriptRoot)\${Folder_Text_To_Speech}(${filenumber})_tts.wav
	
	
	# test
	#break
	}






