# ffmpeg Recipes

Max Rottersman (Maxotics) Collection.  Links to those I learned from at bottom.

*Some of these are "dirty" or not generic.*

### Webcam and Microphones

Get list of devices on a Windows PC, like webcams and microphones

```
ffmpeg -list_devices true -f dshow -i dummy
```

To write those devices to a text file

```
ffmpeg -list_devices true -f dshow -i dummy > my_devices_for_ffmpeg.txt
```

### Portrait "Shorts"

If I want to place a video (footage or webcam), shrunk by 40pix on each side, slightly up from center (600px), over a 1080x1920 png file (pg.png).  

```
ffmpeg -i input.mp4 -i bg.png -filter_complex "[0:v]scale=1000:528[vid];[1:v][vid]overlay=40:600[out]" -map 0:a -map [out] -y output_portrait.mp4
```

If want to add captions I'm using [Microsoft Azure Speech to Text Service](https://learn.microsoft.com/en-us/azure/cognitive-services/speech-service/index-speech-to-text) to generate them from the command line (takes some setting up). 

```
spx recognize --file input.mp4 --format any --output srt file captions.srt
```

I then convert the srt to ass file so I can change the text formatting using [AEGISUB software](https://aegisite.vercel.app/)

```
ffmpeg -i captions.srt captions.ass
```

I then add the subtitle to the video:

```
 ffmpeg -i output_portrait.mp4 -vf ass=captions.ass -y output_portrait_captioned.mp4
```

If I want to do webcam/vide over a blurred copy of itself in portrait I can use:

```
ffmpeg -i webcam.mp4 -filter_complex "[0:v]boxblur=40,scale=1080x1920,setsar=1[bg];[0:v]scale=1080:1920:force_original_aspect_ratio=decrease[fg];[bg][fg]overlay=y=(H-h)/2" -c:a copy webcam_port.mp4
```

This is the "Old TV" effect.  I put my webcam in portrait mode and it rotates it using "transpose=2"

```
ffmpeg -f dshow -rtbufsize 2G -s 1280x720 -i video="Elgato Facecam":audio="In 1-2 (MOTU M Series)" -vf [in]eq=brightness=0.1,eq=contrast=1.5:saturation=1[eq];[eq]drawbox=t=20,drawgrid=w=20,boxblur=3:1,lenscorrection=k1=0.1[out];[out]transpose=2[out2] -c:v h264_nvenc -b:v 0 -maxrate:v 300000K -c:a aac -b:a 128k -y webcam.mp4
```

### Audio

Normalize

```
ffmpeg -i webcam.mp4 -filter:a loudnorm webcam_normalized.mp4
```

Get length of video (> tempvideolength.txt at end to write to file)

```
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 input.mp4
```

Cut and fade out audio

```
 ffmpeg -i source.mp3 -ss 00:00:00 -t 00:00:56 -filter_complex "afade=type=out:duration=5:start_time=51" source_fade_and_cut.wav
```

Create a video from an image and audio file

```
ffmpeg -loop 1 -i image.jpg -i audio.wav -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest image_plus_audio.mp4
```

Or to a specific amount of time

-t 11 (after audio params)

## Overlaying

When overlaying, the 2nd linkname, here [1:v] is layered OVER the first, [0:v]

```
ffmpeg -i mybackground.mp4 -c:v libvpx-vp9 -i what_I_want_to_overlay.webm -filter_complex "[0:v][1:v]overlay=y=800" -map 0:a final_short.mp4
```

Overlay caption PNG on background PNG and create video to length of audio.  This won't work for 1 second vids (audio file), you'll need to check audio length and if under a couple of seconds set -t 2.

```
ffmpeg -loop 1 -i backgrounds\bg_yellow.jpg -i Text_to_Speech\1_tts.mp3 -i captions\1caption.png -filter_complex "[2:v] format=rgba[ovr];[0:v][ovr] overlay=90:1300" -c:v libx264 -c:a copy -pix_fmt yuv420p -r 30 -shortest -y out.mp4
```



## For Editing

Concat files

```
ffmpeg -f concat -safe 0 -i files.txt -c copy -y final_output.mp4
```

Add timecode as a text box onto a video

```
ffmpeg -i myvideo.avi -vf "drawtext=text='%{pts\:hms}':fontfile=tahoma.ttf:fontsize=48:fontcolor=white:box=1:boxborderw=6:boxcolor=black@0.75:x=(w-text_w)/2:y=h-text_h-20" -c:a copy myvideo_TIMECODE.avi
```

Cut video to 1 minute, for example

```
ffmpeg -i myvid.webm -ss 00:00:01 -to 00:01:01 -c:v copy -c:a copy myvid_1min.webm
```

### Resize and Frame Rate

```
ffmpeg -i myfile.mp4 -vf "fps=30,scale=720:1280" -c:v  libx264 -c:a aac -b:a 128k -y "vid_720_30fps.mp4"
```

### Speed Up

```
ffmpeg -i maxrant.mp4 -crf 30 -filter_complex "[0:v]setpts=.8*PTS[v];[0:a]atempo=1.25[a]" -map "[v]" -map "[a]" -y maxrant_spedup25.mp4

x = speedup
So audio, say 1.20
then 1/1.20 = .8
```

## Constants / Properties

```
\ = escape special character in ffmpeg

We may define x and y properties as a math expression and FFmpeg provides variables like (filtergraph timeline):

- w , h— width/height of input video;
- tw , th —width/height of the rendered text

‘t’
timestamp expressed in seconds, NAN if the input timestamp is unknown

‘n’
sequential number of the input frame, starting from 0

‘pos’
the position in the file of the input frame, NAN if unknown

Timeline, enable effect at 3 seconds and end at 20 seconds
enable='between(t,3,20)

-f lavfi (virtual color video stream)

ffmpeg -f lavfi -i color=color=red -t 30 red.mp4
                     ^     ^    ^
                     |     |    |
                   filter key value
```

## ffplay (learn basics or play video)

play a blue background

```
ffplay -f lavfi -i color=color=blue -vf scale=1280x720,fps=20
```

play with text

```
ffplay -f lavfi -i color=color=blue -vf scale=1280x720,fps=20,drawtext=text=Max:fontsize=80
```

## Motion Graphics

Fly in from right

```
x=tw-min(4*(tw\+10)-(abs(4-2*(t-1)))*(tw+10)-tw\,w/3.5)
```

Let's make that readable in pseudo code

x = text width minus the minimum of (4 * (text width + 10)) minus (the absolute number of (4-2 times (time minus 1))) times (text width + 10) - (text width + 10) , width divided by 3.5

It looks weird above, but the \ is the ffmpeg escape char so the end up there is -tw,w/35

Text example fly in from right

```
ffplay -f lavfi -i color=color=blue -vf scale=1280x720,fps=20,drawtext=text="Max Was Here!":fontsize=80:x=tw-min(4*(tw\+10)-(abs(4-2*(t-1)))*(tw+10)-tw\,w/3.5)
```

fly in from left

```
:x=min(4*(tw\+10)-(abs(4-2*(t-1)))*(tw+10)-tw\,w/3.5)
```

###### Lower Thirds, slow fly in from left 

```
ffplay -f lavfi -i color=color=black@0.0:size=1920x1080,format=rgba -vf scale=1280x720,fps=20,drawtext=text="Max Rottersman":fontsize=80:y=h*.8:x=min(1*(t*100)\,100):box=1:boxcolor=gray:boxborderw=10:alpha=.8,drawtext=text="Maxotics":fontsize=40:y=h*.92:x=min(1*(t*100)\,100):box=1:boxcolor=gray:boxborderw=8:alpha=.7
```

Save as a transparent webm file

```
ffmpeg -f lavfi -i color=color=black@0.0:size=1920x1080,format=rgba -vf scale=1280x720,fps=20,drawtext=text="Max Rottersman":fontsize=80:y=h*.8:x=min(1*(t*100)\,100):box=1:boxcolor=gray:boxborderw=10:alpha=.8,drawtext=text="Maxotics":fontsize=40:y=h*.92:x=min(1*(t*100)\,100):box=1:boxcolor=gray:boxborderw=8:alpha=.7 -t 5 -c:v libvpx-vp9 -b:v 2M -y test1.webm
```

Centered title

```
ffplay -f lavfi -i color=color=black@0.0:size=1920x1080,format=rgba -vf scale=1280x720,fps=20,drawtext=text="Max Rottersman":fontsize=80:y=(h-text_h)/2:x=(w-text_w)/2:box=1:boxcolor=gray:boxborderw=10:alpha=.9
```

Slide in from left

```
ffplay -f lavfi -i color=color=black@0.0:size=1920x1080,format=rgba -vf scale=1280x720,fps=20,drawtext=text="Max Rottersman":fontsize=80:y=(h-text_h)/2:x=min(x*t,(w-text_w)/2):box=1:boxcolor=gray:boxborderw=10:alpha=.9
```

stop of a filter at a certain number of frames

```
ffplay -f lavfi -i color=color=blue -vf scale=1280x720,fps=20,drawtext=text="Max Was Here!":fontsize=80:x=min(4*(tw\+10)-(abs(4-2*(t-1)))*(tw+10)-tw\,w/3.5):enable='lte(n,60)
```

More info about lt=less than, lte3 = less than or equal, and the enable stuff here.  Basically allows you to say when in time something should happen or not happen [drawtext examples](https://ffmpeg.org/ffmpeg-filters.html#Examples-71) and sytax, which contains explanation of tw, th, etc. [syntax](http://ffmpeg.org/ffmpeg-filters.html#Syntax)

## Stabilization

From https://www.paulirish.com/

```
ffmpeg -i clip.mkv -vf vidstabdetect -f null -

*# The second pass ('transform') uses the .trf and creates the new stabilized video.*

ffmpeg -i clip.mkv -vf vidstabtransform clip-stabilized.mkv
```



## Text

2 lines of text

```
ffplay -f lavfi -i color=color=blue -vf scale=1280x720,fps=20,drawtext=text="Max Was Here!":fontsize=80:x=50:y=50,drawtext=text="Max Was Here Too!":fontsize=60:x=50:y=150
```

### Scroll Up Text From File Overlay Short

```
LARGE SCROLLING TEXT FOR SHORTS

* WORKING 
* y=(h-100*(t/3))-(h/3)
* or start with height 'y' - 100 pixels, then multiple by time factor for movement
* - MINUS the height factor, where up the screen the scrolling text starts from (h/3 = 1/3d up screen)

* TESTING

ffmpeg -f lavfi -i color=c=black:s=1080x1920:r=30 -filter_complex  "[0]split[txt][orig];[txt]drawtext=fontfile=tahoma.ttf:fontsize=80:fontcolor=green:x=100:y=(h-100*(t/2))-(h/2):textfile=Scroll.txt:bordercolor=white:borderw=3[txt];[orig]crop=iw:50:0:0[orig];[txt][orig]overlay" -c:v  libx264 -c:v h264 -f matroska - | ffplay -

* PRODUCTION

ffmpeg -i NYT_scroll.mp4 -filter_complex  "[0]split[txt][orig];[txt]drawtext=fontfile=tahoma.ttf:fontsize=80:fontcolor=green:x=100:y=(h-100*(t/2))-(h/2):textfile=Scroll.txt:bordercolor=white:borderw=3[txt];[orig]crop=iw:50:0:0[orig];[txt][orig]overlay" -c:v  libx264 -y NYT_scroll_with_text_scrolling.mp4
```



## Window Batch Tricks

```winBatch
setlocal
REM | change to current folder
pushd "%~dp0"

@echo off

REM drag and drop file to extract audio from into variable "file_name"
set "file_name=%~1"

REM Mono 16bit audio (voice) is generally all I need
REM uses existing file name (stem), %~n1, and adds "_audio.wav" to end for
REM output file name
ffmpeg -i %file_name% -vn -acodec pcm_s16le -ac 1 -ar 16000 %~n1_audio.wav

popd
```

Another take

```
setlocal
REM | change to current folder
pushd "%~dp0"
REM drag and drop file to extract audio from into variable "file_name"
set file_name_input="%~1"
set file_name_output="%~1_normalized.wav"

echo %file_name_input%
echo %file_name_output%
REM pause

@echo off

ffmpeg -i %file_name_input% -filter:a loudnorm -y %file_name_output%

popd
```



If we want to create an output video in the same format, say mp4.  NOTE: If we have % in our ffmpeg command double it to escape in winBatch.

```
@echo off
REM drag and drop file to background removed video

set "file_name=%~1"

REM add timecode to video (-c:a copy remove audio -an)
ffmpeg -i %file_name% -ss 00:00:00 -to 00:00:59 -r 30 -vf  "drawtext=text='%%{pts\:hms}':fontfile=tahoma.ttf:fontsize=48:fontcolor=white:box=1:boxborderw=6:boxcolor=black@0.75:x=(w-text_w)/2:y=h-text_h-40" -an -y %~n1_1minute_timecode%~x1

popd
```



## Synchronize Audio (win batch format)

Step 1: Add Timecode to a video

```
ffmpeg -i "%~nx1" -ss 00:00:00 -to 00:00:59 -vf  "drawtext=text='%%{pts\:hms}':fontfile=tahoma.ttf:fontsize=48:fontcolor=white:box=1:boxborderw=6:boxcolor=black@0.75:x=(w-text_w)/2:y=h-text_h-20" -c:a copy -y ""%~n1_timecode%~x1"
```

Step 2: Create waveform visualization for external audio

```
ffmpeg -i "%~nx1" -ss 00:00:00 -to 00:00:59 -filter_complex "[0:a]showwaves=s=1280x720:mode=line:rate=30,format=yuv420p[v]" -map "[v]" -map 0:a -r 30 -y "%~n1_waveform.mp4"
```

Step 3: Put that waveform visualization through step 1 to add timecode on bottom.

Step 4: After calculating time of silence before external audio, create audio file of silence at that length.

```
ffmpeg -f lavfi -t %t_silence% -i anullsrc=cl=mono -y silence_to_sync_audio.wav
```

Step 5: Add the above silence to the original external audio (file) for new audio file that should be synched to original video

```
ffmpeg -i "silence_to_sync_audio.wav" -i "extaudio.mp3" -filter_complex [0:0][1:0]concat=n=2:v=0:a=1[out] -map [out] -y "extaudio_synced.wav"
```

Now replace audio in original video with new external audio (that had silence added to begin to synch it up)

```
ffmpeg -i video.mp4 -i extaudio_synced.wav -c:v copy -map 0:v:0 -map 1:a:0 -y  video_synced_extaudio.mp4
```



## CODECS

#### ProRes

```
-c:v prores_ks -profile:v 3 -vendor apl0 -bits_per_mb 8000 -pix_fmt yuv422p10le 

0 ............ ........................ProRes 422, Proxy
1 ............ ........................ProRes 422, LT
2 .................................... ProRes 422, Standard
3 ........... .........................ProRes 422, HQ
```

## NVENC

Ignore profiles and presets. The higher the bitrate, the better the quality.  It will say what while capturing

```
ffmpeg -f dshow -rtbufsize 2G -i video="Elgato Facecam":audio="In 1-2 (MOTU M Series)" -c:v h264_nvenc -b:v 0 -maxrate:v 300000K -c:a aac -b:a 128k -y webcam2nvenc.mp4
```

For screen grabbing

```
ffmpeg -f gdigrab -show_region 1 -framerate 30 -video_size 1920x1080 -offset_x 100 -offset_y 100 -i desktop -c:v h264_nvenc -b:v 0 -maxrate:v 1M -bufsize:v 1M -y my screencap.mp4
```

### Windows PowerShell

Trick to pipe a command from a Powershell script (or from a PS command prompt) when it doesn't work as expected (these are rare cases probably).  In this case, I need to pipe ffmpeg to ffplay. 

1. Send the whole command with pipe (|) to CMD.exe using "CMD /S /C --%" 
2. Wrap whole thing in double quotes (the /S will strip them when piping) 
3. Use a caret (^) in front of any double-quotes within the ffmpeg arguments, around -filter_complex, for example. EXAMPLE: WILL WORK IN CMD BUT NOT PS:v ffmpeg -f lavfi -i color=c=black:s=1920x1080:r=30 -filter_complex "drawtext=text='Hello!':fontfile='C\:\\Windows\\Fonts\\arial.ttf':fontsize=120:y=((h-text_h)/2)-(text_h):x=(w-text_w)/2:box=1:boxcolor=gray:boxborderw=10:alpha=.9:y=h*.5:x=min((t-0)*120\,(w-text_w)/2):enable='between(t,0,7)'[t1];[0:v][t1]overlay=format=auto,format=yuv420p "  -c:v h264 -profile:v baseline -pix_fmt yuv420p -preset ultrafast -tune zerolatency -crf 28 -g 60 -f matroska - | ffplay -  

This WILL work in PS: cmd /s /c --% "ffmpeg -f lavfi -i color=c=black:s=1920x1080:r=30 -filter_complex ^"drawtext=text='Hello!':fontfile='C\:\\Windows\\Fonts\\arial.ttf':fontsize=120:y=((h-text_h)/2)-(text_h):x=(w-text_w)/2:box=1:boxcolor=gray:boxborderw=10:alpha=.9:y=h*.5:x=min((t-0)*120\,(w-text_w)/2):enable='between(t,0,7)'[t1];[0:v][t1]overlay=format=auto,format=yuv420p ^"  -c:v h264 -profile:v baseline -pix_fmt yuv420p -preset ultrafast -tune zerolatency -crf 28 -g 60 -f matroska - | ffplay -  "

```
# For testing 
$ffplay_start = "cmd /s /c --% `"ffmpeg -f lavfi -i color=c=black:s=1280x720:r=30 -filter_complex  ^`""
$ffplay_end = "[t1];[0:v][t1]overlay=format=auto,format=yuv420p ^`"  -c:v h264 -profile:v baseline -pix_fmt yuv420p -preset ultrafast -tune zerolatency -crf 28 -g 60 -f matroska - | ffplay -  `""

# For production
$ffmpeg_start = "ffmpeg -i `$(`$Filename_Input) -filter_complex `""
$ffmpeg_end = "[t1];[0:v][t1]overlay=format=auto,format=yuv420p`" -y output_titlesadded.mp4"
```

### ffmpeg Gods

[Gyan Doshi](https://superuser.com/users/114058/gyan)  He publishes lateset ffmpeg builds too.  [gyan.dev](https://www.gyan.dev/ffmpeg/)

### YouTube

My fav: [ffmpeg Guy](https://www.youtube.com/@theFFMPEGguy)

## Other Cookbooks

[steven2358](https://gist.github.com/steven2358/ba153c642fe2bb1e47485962df07c730)

[Useful ffmpeg commands by: Amit Agarwal](https://www.labnol.org/internet/useful-ffmpeg-commands/28490/)

