# ffmpeg Recipes

Max Rottersman (Maxotics) Collection

*Some of these are "dirty" or not generic.*

Get list of devices on a Windows PC, like webcams and microphones

```
ffmpeg -list_devices true -f dshow -i dummy
```

To write those devices to a text file

```
ffmpeg -list_devices true -f dshow -i dummy > my_devices_for_ffmpeg.txt
```

## Overlaying

When overlaying, the 2nd linkname, here [1:v] is layered OVER the first, [0:v]

```
ffmpeg -i mybackground.mp4 -c:v libvpx-vp9 -i what_I_want_to_overlay.webm -filter_complex "[0:v][1:v]overlay=y=800" -map 0:a final_short.mp4
```



## For Editing

Add timecode as a text box onto a video

```
ffmpeg -i myvideo.avi -vf "drawtext=text='%{pts\:hms}':fontfile=tahoma.ttf:fontsize=48:fontcolor=white:box=1:boxborderw=6:boxcolor=black@0.75:x=(w-text_w)/2:y=h-text_h-20" -c:a copy myvideo_TIMECODE.avi
```

Cut video to 1 minute, for example

```
ffmpeg -i myvid.webm -ss 00:00:01 -to 00:01:01 -c:v copy -c:a copy myvid_1min.webm
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

## ffplay (learning, use ffmpeg to save to file)

play a blue background

```
ffplay -f lavfi -i color=color=blue -vf scale=1280x720,fps=20
```

play with text

```
ffplay -f lavfi -i color=color=blue -vf scale=1280x720,fps=20,drawtext=text=Max:fontsize=80
```

### Powershell

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



## Other Cookbooks

[steven2358](https://gist.github.com/steven2358/ba153c642fe2bb1e47485962df07c730)