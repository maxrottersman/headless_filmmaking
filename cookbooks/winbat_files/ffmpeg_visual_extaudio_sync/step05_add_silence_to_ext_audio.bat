setlocal
pushd "%~dp0"

REM Concatenate our SILENCE FILE + EXTERNAL AUDIO FILE = NEW WAV FILES

ffmpeg -i "silence_to_sync_audio.wav" -i "extaudio.mp3" -filter_complex [0:0][1:0]concat=n=2:v=0:a=1[out] -map [out] -y "extaudio_synced.wav"

REM pause

REM note, had to take out single quotes in filter_complex to make it work in batch mode