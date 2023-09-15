import librosa
import soundfile as sf
import resampy
import numpy as np

# Load the audio file
try:
    # Desired lower sampling rate
    audio_file = r"soundonly.wav"

    desired_sr = 15000  # 12kHz sampling rate would be 12000
    target_quantization_level = 2**6  # 7-bit quantization

    audio_file_target = "15khz_" + audio_file
    audio_file_target_requantized = "15khz_6bit_" + audio_file
   

    y, sr = librosa.load(audio_file, sr=None)  # Automatically determines the original sampling rate

    ####################################
    # Let's normalize
    ####################################
    # Calculate the peak amplitude of the audio
    max_amplitude = np.max(np.abs(y))

    # Set the desired target amplitude (e.g., 1.0 or -1.0)
    target_amplitude = 1.0

    # Normalize the audio by scaling it
    normalized_audio = y * (target_amplitude / max_amplitude)

    # Resample the audio to the desired sampling rate
    y_resampled = resampy.resample(normalized_audio, sr, desired_sr)

    # Ensure that the lengths of both signals are the same
    min_len = min(len(y), len(y_resampled))
    y = y[:min_len]
    y_resampled = y_resampled[:min_len]

    # Save the resampled audio for further evaluation (optional)
    sf.write(audio_file_target, y_resampled, desired_sr)

    ########################################
    # now let's same it to a lower bit dpeth
    ########################################
    # Quantize the audio to 6 bits
    # Assuming the audio has a range from -1 to 1, you can quantize it to 6 bits (64 levels)
    # First, scale the audio to the range [0, 1]
    y_scaled = (y_resampled - np.min(y_resampled)) / (np.max(y_resampled) - np.min(y_resampled))

    # Then, quantize to 6 bits
    quantization_levels = target_quantization_level
    y_quantized = np.floor(y_scaled * quantization_levels) / (quantization_levels - 1)

    # Convert the quantized audio back to its original range
    y_quantized = y_quantized * (np.max(y_resampled) - np.min(y_resampled)) + np.min(y_resampled)

    # Open a binary file for writing
    with open("raw_audio_data.bin", "wb") as file:
        # Write the array data as binary
        file.write(y_quantized.tobytes())

    # Save the resampled and quantized audio to a 24-bit output file
    sf.write(audio_file_target_requantized , y_quantized, desired_sr, subtype='PCM_24')
    # Listen to the original and resampled audio to evaluate audio quality
    # You can use a program like Audacity or a Python library like playsound to play the audio.

    # Calculate signal-to-noise ratio (SNR) as an objective measure of audio quality
    import numpy as np

    # Calculate SNR for the original audio
    snr_original = 10 * np.log10(np.sum(y ** 2) / np.sum((y - y_resampled) ** 2))

    # Calculate SNR for the resampled audio
    snr_resampled = 10 * np.log10(np.sum(y_resampled ** 2) / np.sum((y_resampled - y) ** 2))

    print(f"SNR of Original Audio: {snr_original} dB")
    print(f"SNR of Resampled Audio: {snr_resampled} dB")

except Exception as e:
    print(f"An error occurred while loading the audio: {e}")