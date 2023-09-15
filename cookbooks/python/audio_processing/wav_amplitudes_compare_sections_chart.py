import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile

# test files
s24file = r"AllTheginJoints.wav"
#mySuptitle = "SoundDesign 24 vs 32 Float"

# Which samples do I want to chart?
myFrame_start = 2000 #600
myFrame_end = 2100 #800
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
axes[0].set_title("Data")
axes[0].set_xlabel("Sample")
axes[0].set_ylabel("Amplitude")

# 2nd Framset
# Which samples do I want to chart?
myFrame_start = 4000 #600
myFrame_end = 4100 #800
myframe_slice = slice(myFrame_start, myFrame_end)
# Take the first 100 samples (adjust as needed)
first_100_samples2 = audio_data[myframe_slice]

# Create the chart
axes[1].plot(time, first_100_samples2, label="Amplitude 2nd Set")
axes[1].set_title("Data")
axes[1].set_xlabel("Sample")
axes[1].set_ylabel("Amplitude")

plt.suptitle("Compare", fontsize=16)

# Add spacing between subplots
plt.tight_layout()

# Show the figure with both subplots
plt.show()
