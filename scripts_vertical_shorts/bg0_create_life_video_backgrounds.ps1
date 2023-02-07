# Load Project Settings We Have in our settings.ini file. Explanation below
Get-Content ".\settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0)-and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
	 
$ProjectWidth = $h.Get_Item("ProjectWidth")
$ProjectHeight = $h.Get_Item("ProjectHeight")

Write-Host $ProjectWidth x $ProjectHeight
#break
	 
$captions = Import-Csv .\captions.txt -delimiter "|"
$caption_folder = "captions\"
$jpgs_folder = "jpgs\"
$output_videos = "output_videos\filter_life\"
$idx = 1

# last 2 repeat first 2
$ColorPairA = @("#539CFF", "#1820FF","#2F3C7E", "#F96167", "#E2D1F9", "#CCF381", "#ADD8E6", "#0011FF", "#EC449B", "#CC313D", "#2F3C7E","#539CFF", "#2F3C7E")
$ColorPairB = @("#A47FFF",  "#E715FF","#FBEAEB", "#FCE77D", "#317773", "#4831D4", "#00008B", "#F6F5FF", "#99F443", "#F7C5CC", "#FBEAEB","#A47FFF", "#FBEAEB")

	ForEach ($caption in $captions){
	$filenumber = $($caption.FILENUMBER)
	$lengthseconds = $($caption.LENGTHSECONDS)
	$captiontext = $($caption.CAPTIONTEXT)

	Write-host $filenumber $captiontext
	
	$frames = ([int]$lengthseconds * 30)
	
	if ($idx % 2)
	{
	$cmd = "ffmpeg -f lavfi -i life=s=$($ProjectWidth)x$($ProjectHeight):mold=10:r=60:ratio=0.1:death_color=$($ColorPairA[$idx]):life_color=$($ColorPairB[$idx]),scale=$($ProjectWidth):$($ProjectHeight) -frames:v $($frames) -r 30 -y $output_videos$($filenumber)panned.mkv"
	}
	else
	{
	$cmd = "ffmpeg -f lavfi -i life=s=$($ProjectWidth)x$($ProjectHeight):mold=10:r=100:ratio=0.1:death_color=$($ColorPairA[$idx]):life_color=$($ColorPairB[$idx]),scale=$($ProjectWidth):$($ProjectHeight),boxblur=2:2 -frames:v $($frames) -r 30 -y $output_videos$($filenumber)panned.mkv"	
	}
	$idx += 1
	Write-host  $cmd
	Invoke-Expression $cmd
	#break
	}
	
# NOTES
# How to get settings from ini file
# https://www.catapultsystems.com/blogs/use-a-settings-file-for-your-powershell-scripts/


