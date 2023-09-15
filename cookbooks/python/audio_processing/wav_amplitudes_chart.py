import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile

# test files
s24file = r"test24.wav"
s32file = r"test32float.wav"
mySuptitle = "SoundDesign 24 vs 32 Float"


# Which samples do I want to chart?
myFrame_start = 2000 #600
myFrame_end = 2200 #800
myframe_slice = slice(myFrame_start, myFrame_end)

# Create a 1x2 grid of subplots
fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(12, 6))
# Load the WAV files3
sample_rate, audio_data = wavfile.read(s24file)
# Take the first 100 samples (adjust as needed)
first_100_samples = audio_data[myframe_slice]
# Convert 32-bit float values to a suitable range (-1 to 1)
#normalized_samples = np.float32(first_100_samples) / np.iinfo(np.int32).max
normalized_samples = np.int32(first_100_samples) / np.iinfo(np.int32).max
# Create a time array based on the sample rate
time = np.arange(0, len(normalized_samples)) / sample_rate

# Create the chart
axes[0].plot(time, normalized_samples)
axes[0].set_title("24-bit Data")
axes[0].set_xlabel("Sample")
axes[0].set_ylabel("Amplitude")

# Load the WAV files3
sample_rate32, audio_data32 = wavfile.read(s32file)

# Take the first 100 samples (adjust as needed)
first_100_samples32 = audio_data32[myframe_slice]

# Convert 32-bit float values to a suitable range (-1 to 1)
normalized_samples32 = np.float32(first_100_samples32) / np.iinfo(np.int32).max

# Create a time array based on the sample rate
time32 = np.arange(0, len(normalized_samples32)) / sample_rate32

# Create the chart
axes[1].plot(time32, normalized_samples32, label="Amplitude 32-bit Float")
axes[1].set_title("32-bit Float Data")
axes[1].set_xlabel("Sample")
axes[1].set_ylabel("Amplitude")

plt.suptitle(mySuptitle, fontsize=16)

# Add spacing between subplots
plt.tight_layout()

# Show the figure with both subplots
plt.show()
