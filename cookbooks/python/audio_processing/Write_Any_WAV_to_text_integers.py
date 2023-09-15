import soundfile as sf
import numpy as np

# 8/31/2023 Last Edit

# a_pitch_8bit
s24file = r"test24.wav"
s32file = r"test32float.wav"

sWAVfile = s24file #r"C:\Max_Software\a_Python_projects\audio_learn\Compare32float_24\220829_0009_softer_to_louader.wav"
#sWAVfile = r"C:\Max_Software\a_Python_projects\audio_learn\Compare32float_24\220829_0009F_softer_to_louader.wav"
#sWAVfile = r"C:\Max_Software\a_Python_projects\audio_learn\SampleWAV\a_pitch_8bit.wav"
# Get information about the audio file
info = sf.info(sWAVfile)

print(info)

# Extract the information you need
n_channels = int(info.channels)
subtype = info.subtype  # This gives you the last two characters of the format subtype
n_frame_rate = info.samplerate
n_frames = info.frames
#n_sample_width = info.format_subtype[-2:]
format_is_float = info.format.endswith('FLOAT')

print("Channels: ",n_channels)
print("Subtype: ",subtype)
#print("Sample Width or Bytes: ",n_sample_width)
print("Frame Rate: ",n_frame_rate)
print("Frames: ",n_frames)
print("Format is float:: ",format_is_float)

if subtype == 'FLOAT':
    print("The WAV file is 32-bit float.")
    sFiletarget = '32bit_float_integers.txt'
elif subtype == 'PCM_24':
    print("The WAV file is 24-bit.")
    sFiletarget = '242bit_integers.txt'
elif subtype == 'PCM_16':
    print("The WAV file is 16-bit.")
    sFiletarget = '162bit_integers.txt'
elif subtype == 'PCM_U8':
    print("The WAV file is 8-bit.")
    sFiletarget = '82bit_integers.txt'
else:
    print("The WAV file is not recognized as 24-bit or 32-bit float.")

# if sample_width => 4 let's assumee it's 32 bit float
###################
# If 24-bit or less
###################

if subtype == 'PCM_24' or subtype == 'PCM_16' or subtype == 'PCM_U8':
    if subtype == 'PCM_24':
        dtype = 'int32'
    if subtype == 'PCM_16':
        dtype = 'int16'
    if subtype == 'PCM_U8':
        dtype = 'int16' #'uint8'

    audio_data, sample_rate = sf.read(sWAVfile, dtype=dtype)

    if n_channels == 2:
        print("The WAV file has ",n_channels, " channels. Pulling only 1 channel.")
        audio_data = audio_data[:, 0]

    # NOTE: having trouble with 8 bit
    if subtype == 'PCM_U8':
        #audio_data = audio_data / 2**7
        rescaled_audio_data = ((audio_data + 32768) // 256).astype('uint8')
        audio_data = rescaled_audio_data

    myMax = 0
    myMin = 0

    for i in range(0, len(audio_data)):  # Assuming 32-bit float WAV
        int_value = audio_data[i]
        if int_value > myMax: myMax = int_value
        if int_value < myMin: myMin = int_value

    print("max is: ", myMax)
    print("min is: ", myMin)

    cnt = 1
    with open(sFiletarget, 'w') as f:
        for i in range(0, 1000): 
            int_value = audio_data[i]
            #print(str(int_value))
            f.write(str(int_value) + '\n')
            if cnt > 64000: break
            cnt += 1

###########################
# if 32-bit float
###########################

if subtype == 'FLOAT':
    # Read the audio data using soundfile
    audio_data, sample_rate = sf.read(sWAVfile, dtype='float32')

    if n_channels == 2:
        print("The WAV file has ",n_channels, " channels. Pulling only 1 channel.")
        audio_data = audio_data[:, 0]

    # Scale the float samples to the range of 32-bit POSITIVE integers
    #int_samples = (audio_data * (2 ** 31 - 1)).astype(np.int32)

    # Scale the float samples to the range of 32-bit signed integers (-2^31 to 2^31 - 1)
    int_samples = (audio_data * (2 ** 31)).astype(np.int32)

    # Find the maximum and minimum integer values
    max_int_value = np.max(int_samples)
    min_int_value = np.min(int_samples)

    print("Maximum Integer Value:", max_int_value)
    print("Minimum Integer Value:", min_int_value)

    cnt = 1
    with open(sFiletarget, 'w') as f:
        for i in range(0, 1000): 
            int_value = int_samples[i]
            #print(str(int_value))
            f.write(str(int_value) + '\n')
            if cnt > 64000: break
            cnt += 1

