import wave

# Read the text file containing integers
#with open('video_alac_mono_26secs_integers.txt', 'r') as f:
#    integer_lines = f.readlines()

# Convert integer strings back to integer values
#audio_integers = [int(line.strip()) for line in integer_lines]

# Set WAV file parameters (adjust these according to your original audio)
n_channels = 1
sample_width = 2  # 16-bit
frame_rate = 48000
#n_frames = len(audio_integers)

# Create a new WAV file
wav_file = wave.open('wav_from_video_alac_mono_20secs_integers.wav', 'wb')
wav_file.setnchannels(n_channels)
wav_file.setsampwidth(sample_width)
wav_file.setframerate(frame_rate)
#wav_file.setnframes(n_frames)

# Convert integers to bytes and write to the WAV file

# Method #1, didn't work
#audio_data = bytes([int(i & 0xFF) for i in audio_integers])
#wav_file.writeframes(audio_data)

#Method #2
with open('video_alac_mono_20secs_integers.txt', 'r') as f:
    numeric_values = [int(line.strip()) for line in f]

for value in numeric_values:
    byte_data = value.to_bytes(sample_width, byteorder='little', signed=True)
    wav_file.writeframes(byte_data)

# Close the WAV file
wav_file.close()
