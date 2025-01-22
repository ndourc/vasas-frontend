import pyaudio
import wave
import json
import pyttsx3
from vosk import Model, KaldiRecognizer

def record_audio(output_filename, record_seconds=5):
    chunk = 1024  # Record in chunks of 1024 samples
    sample_format = pyaudio.paInt16  # 16 bits per sample
    channels = 1
    rate = 16000  # Record at 16000 samples per second

    p = pyaudio.PyAudio()  # Create an interface to PortAudio

    print('Recording')

    stream = p.open(format=sample_format,
                    channels=channels,
                    rate=rate,
                    frames_per_buffer=chunk,
                    input=True)

    frames = []  # Initialize array to store frames

    # Store data in chunks for the specified duration
    for _ in range(0, int(rate / chunk * record_seconds)):
        data = stream.read(chunk)
        frames.append(data)

    # Stop and close the stream
    stream.stop_stream()
    stream.close()
    # Terminate the PortAudio interface
    p.terminate()

    print('Finished recording')

    # Save the recorded data as a WAV file
    wf = wave.open(output_filename, 'wb')
    wf.setnchannels(channels)
    wf.setsampwidth(p.get_sample_size(sample_format))
    wf.setframerate(rate)
    wf.writeframes(b''.join(frames))
    wf.close()

def recognize_speech(audio_path, model_path):
    # Load the Vosk model
    model = Model(model_path)

    # Open the audio file
    wf = wave.open(audio_path, "rb")

    # Initialize the recognizer with the model and sample rate
    rec = KaldiRecognizer(model, wf.getframerate())

    recognized_text = ""
    while True:
        data = wf.readframes(4000)
        if len(data) == 0:
            break
        if rec.AcceptWaveform(data):
            result = json.loads(rec.Result())
            recognized_text += result.get('text', '')

    result = json.loads(rec.FinalResult())
    recognized_text += result.get('text', '')

    return recognized_text

def generate_response(user_message):
    # Placeholder function to simulate interaction with the Ollama model
    # Replace this with actual interaction with the Ollama model
    return f"Response to: {user_message}"

def text_to_speech(text):
    engine = pyttsx3.init()
    engine.say(text)
    engine.runAndWait()

if __name__ == "__main__":
    audio_path = 'test_audio.wav'
    model_path = 'vosk_model/vosk-model-small-en-us-0.15'  # Update this path to your Vosk model

    # Record audio from the microphone
    record_audio(audio_path)

    # Recognize speech from the recorded audio
    recognized_text = recognize_speech(audio_path, model_path)
    print("Recognized Text:", recognized_text)

    # Generate a response using the Ollama model
    response_text = generate_response(recognized_text)
    print("Response Text:", response_text)

    # Convert the response text to speech
    text_to_speech(response_text)