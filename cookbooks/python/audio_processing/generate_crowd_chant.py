import requests
import json
import os
import subprocess
import glob
from pydub import AudioSegment
import os

 # Define the path to the script file
script_chant = "You. are. not. the. anointed."
voice_ids_file = r'E:\Files2024_MaxoticsYT\0511_CrowdEffect\Chant1\elevenlabs_ids.txt'
audio_files_folder = r'E:\Files2024_MaxoticsYT\0511_CrowdEffect\Chant1'
mixed_down_audio = r'E:\Files2024_MaxoticsYT\0511_CrowdEffect\Chant1\mixed_audio.mp3'

# to load elevenlabs_ids.txt
def load_lines_from_file(file_path):
    with open(file_path, 'r') as file:
        lines = [line.encode("ascii", "ignore").decode().strip() for line in file.readlines()]
    return lines

# VOICE AUDIO GENERATION
def download_voices(voice_ids, folder_voiced_audio, XI_API_KEY):
    # Iterate over the script segments
    for voice_id in voice_ids:

        print(voice_id)
    
        # Specify the output file
        output_file = os.path.join(folder_voiced_audio, voice_id + '.mp3')

        # Corrected URL with voice_id appended
        url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"

        # Headers including the API key for authentication
        headers = {
            "Accept": "audio/mpeg",
            "xi-api-key": XI_API_KEY,
            "Content-Type": "application/json"
        }

        # Payload without model_id, since voice_id is used
        payload = {
            "text": script_chant,
            "voice_settings": {
                "stability": 0.5,
                "similarity_boost": 0.5,
                "use_speaker_boost": True
            }
        }

        # Making the POST request
        response = requests.post(url, json=payload, headers=headers)

        # Check if the request was successful
        if response.status_code == 200:
            # Save the audio file
            with open(output_file, 'wb') as file:
                file.write(response.content)
                print("processed:", voice_id)
        else:
            print(f"Error: {response.status_code} {response.text}")
        
        # For testing
        #break

def mix_audios(folder_path):
    # List to hold all audio segments
    audios = []

    # Iterate over all files in the folder
    for file in os.listdir(folder_path):
        # Check if the file is an mp3
        if file.endswith(".mp3"):
            # Load the mp3 file
            audio = AudioSegment.from_mp3(os.path.join(folder_path, file))
            # Add the audio to the list
            audios.append(audio)

    # Overlay all audios together
    mixed = audios[0]
    for audio in audios[1:]:
        mixed = mixed.overlay(audio)

    # Export the mixed audio
    mixed.export(mixed_down_audio, format='mp3')


# Call the main function
if __name__ == "__main__":

    # FIRST DELETE MP3 FILES IN THE FOLDER
    # Get a list of all .mp3 files in the folder
    mp3_files = glob.glob(os.path.join(audio_files_folder, "*.mp3"))
    # Iterate over the list of files and remove each one
    for mp3_file in mp3_files:
        os.remove(mp3_file)

    voice_ids = load_lines_from_file(voice_ids_file)
 
    api_key_file = r'E:\Files2024_MCHI\assets\creds\api-key.txt'
    # Open the file and read the API key
    with open(api_key_file, 'r') as file:
        XI_API_KEY = file.read().strip()
   
    # download voices
    download_voices(voice_ids, audio_files_folder, XI_API_KEY)

    # mix down loaded voices
    mix_audios(audio_files_folder)

    