import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from tabulate import tabulate
import wave

# test file using TASCAM Portacapture X6 Built In Mic
s24file = r"C:\Max_Software\a_Python_projects\audio_learn\Compare32float_24\220829_0009_softer_to_louader.wav"
s32file = r"C:\Max_Software\a_Python_projects\audio_learn\Compare32float_24\test24bitOutput.wav"

mySuptitle = "24-bit Compare to 32-bit Float 24-bit Copy"

# Which samples do I want to chart?
myFrame_start = 600
myFrame_end = 800
myframe_slice = slice(myFrame_start, myFrame_end)

############################
# Load the 24-bit WAV files3
############################
sample_rate, audio_data = wavfile.read(s24file)
# Convert 32-bit to 24-bit values
samples_24bit = np.bitwise_and(audio_data >> 8, 0xFFFFFF)
# Take the first 100 samples (adjust as needed)
first_100_samples = samples_24bit[myframe_slice]
#normalized_samples = np.float32(first_100_samples) / np.iinfo(np.int32).max
normalized_samples = np.int32(first_100_samples) #/ np.iinfo(np.int32).max
# Create a time array based on the sample rate
time = np.arange(0, len(normalized_samples)) / sample_rate

######################
# LOAD 32-bit FLOAT
######################
sample_rate32, audio_data32 = wavfile.read(s32file)
# Take the first 100 samples (adjust as needed)
# Convert 32-bit to 24-bit values
samples_24bit32 = np.bitwise_and(audio_data32 >> 8, 0xFFFFFF)

first_100_samples32 = samples_24bit32[myframe_slice]
# Convert 32-bit float values to a suitable range (-1 to 1)
normalized_samples32 = np.float32(first_100_samples32) #/ np.iinfo(np.int32).max
# Create a time array based on the sample rate
time32 = np.arange(0, len(normalized_samples32)) / sample_rate32


list24bit = first_100_samples.tolist()
list32bitfloat = first_100_samples32.tolist()

# Combine lists into a list of tuples for tabulate
combined_list = [(row1, row2) for row1, row2 in zip(list24bit, list32bitfloat)]

# Define headers for the table
headers = ['24-bit Data', '32-bit Float Convert to 24-bit']

# Use tabulate to format and display the table
print(tabulate(combined_list, headers=headers, tablefmt='grid'))


