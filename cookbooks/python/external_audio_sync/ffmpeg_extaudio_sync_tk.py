import subprocess
import re
from pydub import AudioSegment
import os

import tkinter as tk
from tkinterdnd2 import DND_FILES, TkinterDnD

# Specify input and output file names
# source video file

# Global variables
video_file = ""
video_short_tmp = ""
extaudio_file = ""
extaudio_short_tmp = ""
output_file_silence = ""
extaudio_videosynced = ""


def ffmpeg_process_files():

    ###################################################
    # We need to get first 10 seconds of video audio
    ###################################################
    cmd_video_short_tmp = [
        "ffmpeg",
        "-i", video_file,
        "-ss", "0", "-t", "10",
        "-y",
        video_short_tmp
    ]
    print(" ".join(cmd_video_short_tmp))
    #exit()
    try:
        subprocess.run(cmd_video_short_tmp, check=True)
        print("FFmpeg process has finished.")
    except subprocess.CalledProcessError as e:
        print("FFmpeg process failed:", e)


    #########################################################
    # NEXT we need to get first 10 seconds of external audio
    #########################################################
    cmd_extaudio_short_tmp = [
        "ffmpeg",
        "-i", extaudio_file,
        "-ss", "0", "-t", "10",
        "-y",
        extaudio_short_tmp
    ]
    print(" ".join(cmd_extaudio_short_tmp))
    #exit()
    try:
        subprocess.run(cmd_extaudio_short_tmp, check=True)
        print("FFmpeg process has finished.")
    except subprocess.CalledProcessError as e:
        print("FFmpeg process failed:", e)

    #########################################################
    # Find first clap in video audio
    #########################################################
    command = [
        "ffmpeg",
        "-i", video_short_tmp,
        "-af", "astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.Peak_level:file=-",
        "-f", "null", "-"
    ]
    print(" ".join(command))
    proc = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    output_lines = []
    for line in proc.stdout:
        output_lines.append(line.strip())
    proc.communicate()  # Wait for the process to finish and close
    time_pattern = re.compile(r'pts_time:([\d.]+)')
    RMS_peak_pattern = re.compile(r'Peak_level=([-+]?\d*\.\d+|\d+)')
    time_values = []
    peak_values = []
    #for line in lines:
    for line in output_lines:
        #print(line)
        match = time_pattern.search(line)
        if match:
            time_values.append(match.group(1))

        match_peak = RMS_peak_pattern.search(line)
        if match_peak:
            peak_values.append(float(match_peak.group(1)))


    #for time, peak in zip(time_values,peak_values):
    #    print(f"{time}|{peak}")

    # find clap which is 2nd in array x[1] peak
    time_peak = zip(time_values,peak_values)
    # the following eget the max row
    max_row_video = max(time_peak, key=lambda x: x[1])

    print("Video first clap:")
    print(max_row_video)

    #########################################################
    # Find first clap in external audio file
    #########################################################
    command = [
        "ffmpeg",
        "-i", extaudio_short_tmp,
        "-af", "astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.Peak_level:file=-",
        "-f", "null", "-"
    ]
    print(" ".join(command))
    proc = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    output_lines = []
    for line in proc.stdout:
        output_lines.append(line.strip())
    proc.communicate()  # Wait for the process to finish and close
    time_pattern = re.compile(r'pts_time:([\d.]+)')
    RMS_peak_pattern = re.compile(r'Peak_level=([-+]?\d*\.\d+|\d+)')
    time_values_ext = []
    peak_values_ext = []
    #for line in lines:
    for line in output_lines:
        #print(line)
        match = time_pattern.search(line)
        if match:
            time_values_ext.append(match.group(1))

        match_peak = RMS_peak_pattern.search(line)
        if match_peak:
            peak_values_ext.append(float(match_peak.group(1)))

    #for time, peak in zip(time_values_ext,peak_values_ext):
    #    print(f"{time}|{peak}")

    # find clap which is 2nd in array x[1] peak
    time_peak_ext = zip(time_values_ext,peak_values_ext)
    # using max value of 1 row
    max_row_ext = max(time_peak_ext, key=lambda x: x[1])

     # instead, I want to get the max of two values
    max_sum_row = None
    max_sum = float('-inf')

    time_peak = list(zip(time_values_ext, peak_values_ext))
    for i in range(len(time_peak) - 1):
        row_sum = time_peak[i][1] + time_peak[i + 1][1]
        if row_sum > max_sum:
            max_sum = row_sum
            max_sum_row = i

    if max_sum_row is not None:
        print("Max sum row:", time_peak[max_sum_row])
        max_row_ext = time_peak[max_sum_row]
    else:
        print("No valid pairs found")

    print("External audio first clap:")
    print(max_row_ext)

    ######################
    # What is time to add?
    ######################

    add_silence = abs(round(float(max_row_video[0]) - float(max_row_ext[0]),2))
    print ("Silence to add")
    print(add_silence)

    ############################
    # Create silence file to add 
    #############################
    command = [
        "ffmpeg",
        "-f", "lavfi",
        "-t", str(add_silence),
        "-i", "aevalsrc=0",
        "-acodec", "pcm_s16le",
        "-ar", "44100",
        "-ac", "2", "-y",
        output_file_silence
    ]
    subprocess.run(command,check=True)

    ############################
    # Concatenate silenct to ext audio file (add to beginning) 
    #ffmpeg -i "silence_to_sync_extaudio.wav" -i "extaudio.wav" 
    # -filter_complex [0:0][1:0]concat=n=2:v=0:a=1[out] -map [out] -y 
    # "extaudio_videosynced.wav"
    #############################
    command = [
        "ffmpeg",
        "-i", output_file_silence,
        "-i", extaudio_file,
        "-filter_complex", "[0:0][1:0]concat=n=2:v=0:a=1[out]","-map","[out]","-y",
        extaudio_videosynced
    ]
    print(" ".join(command))
    subprocess.run(command,check=True)

    # REM replace audio in original video file with new audio file we created
    # REM that should sync up.  If not, change the duration of our audio leader file
    #ffmpeg -i video.mp4 -i extaudio_videosynced.wav -c:v copy 
    # -map 0:v:0 -map 1:a:0 -y  video_extaudio_videosynced.mp4
    video_file_extaudio = video_file.replace(".mp4", "_extaudio.mp4")
    command = [
        "ffmpeg",
        "-i", video_file,
        "-i", extaudio_videosynced,
        "-c:v","copy", "-map", "0:v:0" ,"-map", "1:a:0", "-y",
        video_file_extaudio
    ]
    subprocess.run(command,check=True)
    print("done")

####################################
# Tkinter GUI build
####################################

def drop_mp4(event):
    filepath = event.data
    mp4_text_box.delete(1.0, tk.END)
    mp4_text_box.insert(tk.END, filepath)

def drop_wav(event):
    filepath = event.data
    wav_text_box.delete(1.0, tk.END)
    wav_text_box.insert(tk.END, filepath)

def drop_mp4(event):
    filepath = event.data
    mp4_text_box.delete(1.0, tk.END)
    mp4_text_box.insert(tk.END, filepath)

def drop_wav(event):
    filepath = event.data
    wav_text_box.delete(1.0, tk.END)
    wav_text_box.insert(tk.END, filepath)

def process_files():
    mp4_filepath = mp4_text_box.get("1.0", tk.END).strip()
    wav_filepath = wav_text_box.get("1.0", tk.END).strip()

    # You can add your processing logic here
    print("Processing .mp4 file:", mp4_filepath)
    print("Processing .wav file:", wav_filepath)

    global video_file
    video_file = mp4_filepath #os.path.join(script_dir, video_file)
    global extaudio_file
    extaudio_file = wav_filepath #os.path.join(script_dir, video_short_tmp)

    global video_short_tmp
    video_short_tmp = "tmp_video10.wav"
    global extaudio_short_tmp 
    extaudio_short_tmp = "tmp_extaudio10.wav"
    
    global output_file_silence
    output_file_silence = "silence_to_sync_extaudio.wav"
     # silence file
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_file_silence = os.path.join(script_dir, output_file_silence)
    
    global extaudio_videosynced
    extaudio_videosynced = os.path.join(script_dir, "extaudio_videosynced.wav")
    
    ffmpeg_process_files()

root = TkinterDnD.Tk()

root.title("Drag and Drop Files")

# Add labels for the text boxes
mp4_label = tk.Label(root, text="Video file:")
mp4_label.pack(padx=10, pady=2)

mp4_text_box = tk.Text(root, wrap=tk.WORD, height=5, width=50)
mp4_text_box.pack(padx=10, pady=2)

mp4_text_box.drop_target_register(DND_FILES)
mp4_text_box.dnd_bind('<<Drop>>', drop_mp4)

wav_label = tk.Label(root, text="External Audio File:")
wav_label.pack(padx=10, pady=2)

wav_text_box = tk.Text(root, wrap=tk.WORD, height=5, width=50)
wav_text_box.pack(padx=10, pady=2)

wav_text_box.drop_target_register(DND_FILES)
wav_text_box.dnd_bind('<<Drop>>', drop_wav)

process_button = tk.Button(root, text="Process Files", command=process_files)
process_button.pack(pady=10)

root.mainloop()