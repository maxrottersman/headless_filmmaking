#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
# Filename_Input|Title|Subtitle|TimeStart|TimeEnd|MyStyle|Position|Filename_Output
# We'll calculate $TimeLength = TimeEnd - TimeStart
$drawtexts = Import-Csv .\drawtext.txt -delimiter "|"
$TimeLength = 0

$flagTest = 0 # 0 false 1 true

# For testing 
$ffplay_start = "cmd /s /c --% `"ffmpeg -f lavfi -i color=c=black:s=1280x720:r=30 -filter_complex  ^`""
$ffplay_end = "[t1];[0:v][t1]overlay=format=auto,format=yuv420p ^`"  -c:v h264 -profile:v baseline -pix_fmt yuv420p -preset ultrafast -tune zerolatency -crf 28 -g 60 -f matroska - | ffplay -  `""

# For production
$ffmpeg_start = "ffmpeg -i `$(`$Filename_Input) -filter_complex `""
$ffmpeg_end = "[t1];[0:v][t1]overlay=format=auto,format=yuv420p`" -y output_titlesadded.mp4"

# REMEMBER! 'n' is frame, 't' is time
$drawtext_Title = "drawtext=text='`$(`$Title)':fontfile='C\:\\Windows\\Fonts\\arial.ttf':fontsize=120:y=(h-text_h)/2:x=(w-text_w)/2:box=1:boxcolor=gray:boxborderw=10:alpha=.9:y=h*.5:x=min((t-`$(`$TimeStart))*120\,(w-text_w)/2):enable='between(t,`$(`$TimeStart),`$(`$TimeEnd))'"

$drawtext_LowerThird_Title = "drawtext=text='`$(`$Title)':fontfile='C\:\\Windows\\Fonts\\arial.ttf':fontsize=80:y=h*.8:x=min((t-`$(`$TimeStart))*120\,(w)/9):box=1:boxcolor=gray:boxborderw=10:alpha=.8:enable='between(t,`$(`$TimeStart),`$(`$TimeEnd))'"

$drawtext_LowerThird_Subtitle = "drawtext=text='`$(`$Subtitle)':fontfile='C\:\\Windows\\Fonts\\arial.ttf':fontsize=40:y=h*.92:x=min((t-`$(`$TimeStart))*120\,(w)/9):box=1:boxcolor=gray:boxborderw=8:alpha=.7:enable='between(t,`$(`$TimeStart),`$(`$TimeEnd))'"

#Write-host $ffmpeg_start

$row = 1
	ForEach ($dt in $drawtexts){
	$Filename_Input = $($dt.Filename_Input)
	$Title = $($dt.Title)
	$Subtitle = $($dt.Subtitle)
	$TimeStart = $($dt.TimeStart)
	$TimeEnd = $($dt.TimeEnd)
	$MyStyle = $($dt.MyStyle)
	$Position = $($dt.Position)
	$Filename_Output = $($dt.Filename_Output)
	
	$TimeLength = $TimeEnd - $TimeStart
	#Write-host "TimeLength: " $TimeLength	
	
	# Get filename stuff from first row, they aren't needed after
		if ($row -eq 1)
		{
#			if ($flagTest -eq 1)
#			{
#			$ffmpeg_cmd = ""	
#			}
#			else
#			{
#			$ffmpeg_cmd = ""
#			}
		}
	
	#Write-host "STUB: " $ffmpeg_cmd	
		
		# For each Loop we want to add the drawtext command
		if ($MyStyle -eq "Title_Centered")
		{
		
		$ffmpeg_cmd = $ffmpeg_cmd + $ExecutionContext.InvokeCommand.ExpandString($drawtext_Title) + ","
		}
		
		# For each Loop we want to add the drawtext command
		if ($MyStyle -eq "Lower_Third")
		{
		$ffmpeg_cmd = $ffmpeg_cmd + $ExecutionContext.InvokeCommand.ExpandString($drawtext_LowerThird_Title) + "," + $ExecutionContext.InvokeCommand.ExpandString($drawtext_LowerThird_Subtitle) 
		}

	$row += 1
	}
	
		if ($flagTest -eq 1)
		{
		#Write-Host "START: "$ffplay_start
		#Write-Host "CMD: "$ffmpeg_cmd
		#Write-Host "END: " $ffplay_end
		$ffmpeg_cmd = $ffplay_start +  $ffmpeg_cmd + $ffplay_end
		#Write-Host $ffmpeg_cmd
		}
		else
		{
		$ffmpeg_cmd	 = $ExecutionContext.InvokeCommand.ExpandString($ffmpeg_start)	+ $ffmpeg_cmd + $ffmpeg_end
		}
		# Remove last command in Drawtext command before linklable
		# ,[t1]
		
		$ffmpeg_cmd = $ffmpeg_cmd.replace(',[t1]','[t1]')
		
Write-Host $ffmpeg_cmd
Invoke-Expression $ffmpeg_cmd
	
# Use ImgageMagick gravity constants for position
#None
#Center
#East
#Forget
#NorthEast
#North
#NorthWest
#SouthEast
#South
#SouthWest
#West


