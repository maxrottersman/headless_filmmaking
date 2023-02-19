# Load Project Settings We Have in our settings.ini file. Explanation below
Get-Content ".\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0)-and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

# for now, will assume everything under 60 seconds

# Config from settings.ini file
$VideoNeedingAudio = "FINAL_compiled.mkv"
$AudioPathAndFileBackground = $h.Get_Item("AudioPathAndFileBackground")
$AudioForBackground = "audioforbackground_faded_and_cut.wav"

$duration = ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ${VideoNeedingAudio}
$duration = [int]$duration

Write-Host $duration
	
#calculate padding necessary to make proper length
#$Add_Duration = [math]::[Double]${lengthseconds}-[math]::[Double]${duration}
$FadeOutStart = ${duration}-5 
Write-Host $FadeOutStart

ffmpeg -i ${AudioPathAndFileBackground} -ss 00:00:00 -t 00:00:${duration} -filter_complex "afade=type=out:duration=5:start_time=${FadeOutStart}" -y ${AudioForBackground}

ffmpeg -i ${VideoNeedingAudio} -i ${AudioForBackground} -c:v copy -map 0:v:0 -map 1:a:0 -y FINAL_compiled_with_audio.mp4
# ffmpeg -i v.mp4 -i a.wav -c:v copy -map 0:v:0 -map 1:a:0 new.mp4

# test
#break





