from models.tts_models import SynthesisResponse, VoicesResponse
import os
import azure.cognitiveservices.speech as speechsdk


class TTSService:
    def __init__(self):
        self.voices_by_language = {
            "es": ["default", "female_1", "male_1"],
            "en": ["default", "female_1", "male_1"],
        }

    async def synthesize(self, text: str, language: str, voice: str) :
        api_key = os.getenv("AZURE_API_KEY")
        location = os.getenv("AZURE_LOCATION")
        pathAudio = os.getcwd()
        print(pathAudio)
        folderAudio= "/audio_files/"
        os.makedirs(pathAudio + folderAudio, exist_ok=True)     

        speech_config = speechsdk.SpeechConfig(subscription=api_key, region=location)
        speech_config.speech_synthesis_voice_name = f"{language}-{voice}"

        full_path = pathAudio + folderAudio
        temp_path = os.path.join(full_path, "temp_output.mp3")
        audio_config = speechsdk.audio.AudioOutputConfig(filename=temp_path)

        speech_synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config, audio_config=audio_config)

        result = speech_synthesizer.speak_text_async(text).get()

        if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
            final_name = f"{result.result_id}.mp3"
            audio_file_path = os.path.join(full_path, final_name)

            # Graba directamente el archivo
            audio_config = speechsdk.audio.AudioOutputConfig(filename=audio_file_path)
            speech_synthesizer = speechsdk.SpeechSynthesizer(
                speech_config=speech_config, audio_config=audio_config
            )
            # Segunda llamada: guarda en el archivo final
            speech_synthesizer.speak_text_async(text).get()

            response = {
                "status": "success",
                "text": text,
                "language": language,
                "voice": voice,
                "file": audio_file_path,
                "reason": str(result.reason),
                "size_bytes": os.path.getsize(audio_file_path),
                "filename": final_name,
            }
            print(f"✅ Audio generado: {audio_file_path}")
            return response
    
        elif result.reason == speechsdk.ResultReason.Canceled:
            cancellation_details = result.cancellation_details
            error_msg = {
                "status": "error",
                "text": text,
                "language": language,
                "voice": voice,
                "reason": str(cancellation_details.reason),
                "error_details": cancellation_details.error_details,
            }
            print("❌ Error en síntesis: ", error_msg)
            return error_msg
        return result

    async def get_available_voices(self) -> VoicesResponse:
        return VoicesResponse(
            languages=self.voices_by_language,
            default={lang: "default" for lang in self.voices_by_language.keys()},
        )


