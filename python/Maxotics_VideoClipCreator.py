import tkinter as tk
from tkinterdnd2 import TkinterDnD, DND_FILES
import subprocess
import pyautogui
import pygetwindow as gw
import time
import os

# Global variables to store the source file name and the proxy file name
source_filename = ''
proxy_filename = ''

# Global variable to store the filename
mpv_player_exe = r'C:\Max_Software\MPV_2024\mpv.exe'
filename = ''

def drop(event):
    global source_filename
    global proxy_filename
    source_filename = event.data
    text_box3.delete(0, 'end')
    text_box3.insert('end', source_filename)

    # Create the proxy file name by adding "_proxy" to the source file name
    base_name = os.path.splitext(source_filename)[0]
    proxy_filename = base_name + '_proxy.avi'

    # Insert the source file name and the proxy file name into their respective text boxes
    source_text_box.delete(0, 'end')
    source_text_box.insert('end', source_filename)
    proxy_text_box.delete(0, 'end')
    proxy_text_box.insert('end', proxy_filename)

def play():
    global filename
    if filename:
        scripts_dir = r'C:\Max_Software\MPV_2024\scripts'
        subprocess.Popen([mpv_player_exe, '--geometry=800x600', '--scripts=' + scripts_dir, filename])
root = TkinterDnD.Tk()

def play_proxy():
    global proxy_filename
    if proxy_filename:
        scripts_dir = r'C:\Max_Software\MPV_2024\scripts'
        subprocess.Popen([mpv_player_exe, '--geometry=800x600', '--scripts=' + scripts_dir, proxy_filename])

def mark_in():
    # Find the MPV player and make it active
    mpv_window = None
    for window in gw.getAllWindows():
        if 'mpv' in window.title.lower():
            mpv_window = window
            break

    if mpv_window is not None:
        mpv_window.activate()
    else:
        print("MPV player not found")

    # Send Ctrl+C to the active window
    pyautogui.hotkey('ctrl', 'c')

    # Wait for the clipboard to be updated
    time.sleep(0.2)

    # Copy the clipboard content to box 1 if it's not too long
    content = root.clipboard_get()
    if len(content) <= 20:
        text_box1.delete(0, 'end')
        text_box1.insert('end', content)

def mark_out():
    # Find the MPV player and make it active
    mpv_window = None
    for window in gw.getAllWindows():
        if 'mpv' in window.title.lower():
            mpv_window = window
            break

    if mpv_window is not None:
        mpv_window.activate()
    else:
        print("MPV player not found")

    # Send Ctrl+C to the active window
    pyautogui.hotkey('ctrl', 'c')

    # Wait for the clipboard to be updated
    time.sleep(0.2)

    # Copy the clipboard content to box 1 if it's not too long
    content = root.clipboard_get()
    if len(content) <= 20:
        text_box2.delete(0, 'end')
        text_box2.insert('end', content)

def create_proxy():
    global source_filename
    global proxy_filename

    # Create the ffmpeg command
    command = [
        'ffmpeg',
        '-i', source_filename,
        '-vf', 'scale=960:540',
        '-vcodec', 'mjpeg',
        '-qscale:v', '31',
        '-c:a', 'aac',
        '-b:a', '192k',
        '-y', proxy_filename
    ]

    # Convert the command to a string
    command_str = ' '.join(command)

    # Insert the command into the ffmpeg text box
    ffmpeg_text_box.delete('1.0', 'end')
    ffmpeg_text_box.insert('end', command_str)

    # Run the ffmpeg command (as part of python process)
    #subprocess.run(command)

    # Run the ffmpeg command in a separate Windows command prompt
    subprocess.run(['cmd', '/c', 'start', 'cmd', '/c', command_str])

def transcode():
    # Get the In point and the Out point
    in_point = text_box1.get()
    out_point = text_box2.get()

    # Get the target file name from the "Save clip as name" box
    target_file_transcode = clip_text_box.get().strip()

    if not target_file_transcode:
        # If the box is empty, use "Clip.mp4" as the default
        target_file_transcode = os.path.join(os.path.dirname(source_filename), 'Clip.mp4')
    else:
        # Add the .mp4 extension to the target file name
        target_file_transcode += '.mp4'

    # Get the directory of the source file
    source_dir = os.path.dirname(source_filename)

    # Create the full path to the target file
    target_file_path = os.path.join(source_dir, target_file_transcode)

    # Create the ffmpeg command
    command = [
        'ffmpeg',
        '-ss', in_point,
        '-to', out_point,
        '-i', source_filename,
        '-c:v', 'libx264',
        '-c:a', 'aac',
        '-b:a', '128k',
        '-y', target_file_path
    ]

    # Convert the command to a string
    command_str = ' '.join(command)

    # Insert the command into the ffmpeg text box
    ffmpeg_text_box.delete('1.0', 'end')
    ffmpeg_text_box.insert('end', command_str)

    # Run the ffmpeg command in a separate Windows command prompt
    subprocess.run(['cmd', '/c', 'start', 'cmd', '/c', command_str])

    # Run the ffmpeg command
    #subprocess.run(command)

# Create buttons
mark_in_button = tk.Button(root, text="Mark In", command=mark_in)
mark_out_button = tk.Button(root, text="Mark Out", command=mark_out)
create_proxy_button = tk.Button(root, text="Create Proxy",command=create_proxy)
play_vid_button = tk.Button(root, text="Play", command=play)

# Create "Play Proxy" button
play_proxy_button = tk.Button(root, text="Play Proxy", command=play_proxy)
#

# Create labels and text boxes
label1 = tk.Label(root, text="In Point:")
text_box1 = tk.Entry(root)
label2 = tk.Label(root, text="Out Point:")
text_box2 = tk.Entry(root)
label3 = tk.Label(root, text="Filename:")
text_box3 = tk.Entry(root)

# Arrange buttons in the first row with padding
mark_in_button.grid(row=0, column=0, padx=5, pady=5, sticky='w')
mark_out_button.grid(row=0, column=1, padx=5, pady=5, sticky='w')
create_proxy_button.grid(row=0, column=2, padx=5, pady=5)
play_vid_button.grid(row=0, column=3, padx=5, pady=5)
# Arrange "Play Proxy" button in the first row with padding
play_proxy_button.grid(row=0, column=4, padx=5, pady=5)

# Arrange "In Point" and "Out Point" labels and text boxes in the second row with padding
label1.grid(row=1, column=0, padx=5, pady=5, sticky='w')
text_box1.grid(row=1, column=0, padx=5, pady=5, sticky='w')
label2.grid(row=1, column=1, padx=5, pady=5, sticky='w')
text_box2.grid(row=1, column=1, padx=5, pady=5, sticky='w')

# Create "Source Filename" label and text box
source_label = tk.Label(root, text="Source Filename")
source_text_box = tk.Entry(root, width=80)

# Arrange "Source Filename" label and text box in the fourth row with padding
source_label.grid(row=2, column=0, padx=5, pady=5, sticky='w')
source_text_box.grid(row=2, column=1, padx=5, pady=5, sticky='w')

# Create "Proxy Filename" label and text box
proxy_label = tk.Label(root, text="Proxy Filename")
proxy_text_box = tk.Entry(root, width=80)

# Arrange "Proxy Filename" label and text box in the fifth row with padding
proxy_label.grid(row=3, column=0, padx=5, pady=5, sticky='w')
proxy_text_box.grid(row=3, column=1, padx=5, pady=5, sticky='w')

# Create "ffmpeg command" label and text box
ffmpeg_label = tk.Label(root, text="ffmpeg command")
ffmpeg_text_box = tk.Text(root, height=3)

# Arrange "ffmpeg command" label and text box in the sixth row with padding
ffmpeg_label.grid(row=4, column=0, padx=5, pady=5, sticky='w')
ffmpeg_text_box.grid(row=4, column=1, padx=5, pady=5, sticky='w')


# Create label and text box for "Clip Save-To-Name"
clip_label = tk.Label(root, text="Clip Save-To-Name")
clip_text_box = tk.Entry(root)

# Arrange label and text box in the fourth row with padding
clip_label.grid(row=5, column=0, padx=5, pady=5)
clip_text_box.grid(row=5, column=2, padx=5, pady=5)

# Create "Process" and "Exit" buttons
process_button = tk.Button(root, text="Process",command=transcode)
exit_button = tk.Button(root, text="Exit", command=root.quit)

# Arrange "Process" and "Exit" buttons in the fourth row with padding
process_button.grid(row=5, column=3, padx=5, pady=5)
exit_button.grid(row=5, column=4, padx=5, pady=5)

# Enable drag and drop
root.drop_target_register(DND_FILES)
root.dnd_bind('<<Drop>>', drop)

root.mainloop()