# Headless Filmmaking: Vertical Shorts From Photos

First, we want to take our photos and set their height to the height of our vertical video (shorts); that is, 1920 in most cases

View: [Sample short created](https://youtube.com/shorts/B_dL4saQyUg?feature=share)


```powershell
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$files = Get-ChildItem ".\*.jpg"
$filenumber = 1ForEach ($file in $files){

	if ($file.Name.Length -gt 5) # we don't want to operate on our short number files
	{
	# or -resize [don't touch lenth]x[make height 1920]
	$cmd = "magick $( $file) -resize x1920  $($scriptPath)\$( $filenumber).jpg"
	
	$filenumber += 1
	Invoke-Expression $cmd
	}
}
```

Now that we have image with 1920 heights, let's pan across them and create a video of that panning.  I this case, we'll do it for 5 seconds for each image.

$captions = Import-Csv .\captions.txt -delimiter "|"

```powershell
ForEach ($caption in $captions){
$filenumber = $($caption.filenumber)
$captiontext = $($caption.captiontext)

# crop=1080:1920:n*6:0, the n=nanoseconds, so move x of the frame 6*nanoseconds
# the larger the multiply factor the faster the pan
$cmd = "ffmpeg -loop 1 -i $($filenumber).jpg -framerate 30 -vf crop=1080:1920:n*6:0 -frames:v 150 -y $($filenumber)panned.mkv"

Invoke-Expression $cmd
}
```

Now that we have our panned videos, let's create some captions for them in a CSV type txt file

```tex
filenumber|captiontext
1|We went to Aeronaut for a beer and shuffleboard...
2|but ended up...
3|Watching...
4|Wrestling!
5|It was silly fun, we all had to admit
6|POW!!!
7|SHAZAM!!!
8|Oh My!
9|Goodbye
```

Each number will be used to work on a video

$captions = Import-Csv .\captions.txt -delimiter "|"

```powershell
ForEach ($caption in $captions){
$filenumber = $($caption.filenumber)
$captiontext = $($caption.captiontext)

$cmd = "magick -size 800x1600 -background none -font Open-Sans-Bold -strokewidth 2  -stroke blue   -undercolor white -gravity center caption:`" $( $captiontext)`"  $( $filenumber)caption.png"

Invoke-Expression $cmd
}
```

Now that we have our captions with a transparent background, let's use them to create transparent videos where they fade in.

$captions = Import-Csv .\captions.txt -delimiter "|"

	ForEach ($caption in $captions){
	$filenumber = $($caption.filenumber)
	
	$cmd = "ffmpeg -i $($filenumber)panned.mkv -loop 1 -i $($filenumber)caption.png -filter_complex `"[1:0] format=rgba,fade=in:st=0:d=3:alpha=1,fade=out:st=6:d=3:alpha=1 [ovr];[0:0][ovr] overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2`" -t 5 -y $($filenumber)addedcaption.mkv"
	
	Invoke-Expression $cmd
	
	}

Finally, let's concat our videos into our final project

```
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

Invoke-Expression $cmd
	
```

