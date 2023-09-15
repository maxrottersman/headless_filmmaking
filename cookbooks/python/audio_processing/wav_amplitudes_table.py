import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile
from tabulate import tabulate
import wave

# test file using TASCAM Portacapture X6 Built In Mic
s24file = r"test24.wav"
s32file = r"test32float.wav"
mySuptitle = "24 vs 32 Float"


# Which samples do I want to chart?
myFrame_start = 2000 #600
myFrame_end = 2200 #800
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
first_100_samples32 = audio_data32[myframe_slice]
# Convert 32-bit float values to a suitable range (-1 to 1)
normalized_samples32 = np.float32(first_100_samples32) #/ np.iinfo(np.int32).max
# Create a time array based on the sample rate
time32 = np.arange(0, len(normalized_samples32)) / sample_rate32

#############################################
# LOAD 32-bit FLOAT values as 24-bit Integers
#############################################

# Minimum and maximum representable values for 32-bit float
#min_32bit_float = np.finfo(np.float32).min
#max_32bit_float = np.finfo(np.float32).max

# Find the maximum absolute value in the float samples
max_float_value = np.max(np.abs(audio_data32))

# Normalize the samples to the range [-1, 1]
normalized_samples = audio_data32 / max_float_value

# Convert to 24-bit integer range
max_24bit_value = 2**23 - 1
scaled_samples = (normalized_samples * max_24bit_value).astype(np.int32)

# Clip values to ensure they stay within 24-bit range
scaled_samples = np.clip(scaled_samples, -max_24bit_value, max_24bit_value)

# Save the 24-bit integer audio file
#wavfile.write('output_24bit.wav', sample_rate, scaled_samples)

# Take the first 100 samples (adjust as needed)
first_100_samples32toInt = scaled_samples[myframe_slice]

# Now you can work with the 24-bit integer audio data


list24bit = first_100_samples.tolist()
list32bitfloat = first_100_samples32.tolist()
list32bitfloattoInt = first_100_samples32toInt.tolist()

# Combine lists into a list of tuples for tabulate
combined_list = [(row1, row2, row3) for row1, row2, row3 in zip(list24bit, list32bitfloat, list32bitfloattoInt)]

# Define headers for the table
headers = ['24-bit Data', '32-bit Float Data', '32-bit Float to Int']

# Use tabulate to format and display the table
print(tabulate(combined_list, headers=headers, tablefmt='grid'))


