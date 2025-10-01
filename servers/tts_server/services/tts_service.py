import os
import azure.cognitiveservices.speech as speechsdk
from models.tts_models import SynthesisResponse, VoicesResponse


class TTSService:
    def __init__(self):
        self.voices_by_language = {
            "es": ["es-ES-AlvaroNeural", "es-ES-ElviraNeural"],
            "en": ["en-US-BrandonMultilingualNeural", "en-US-JennyNeural"]
        }

        # Configuración desde variables de entorno
        self.speech_key = os.getenv("AZURE_API_KEY")
        self.speech_region = os.getenv("AZURE_LOCATION", "eastus")

        # Carpeta donde se guardarán los audios
        self.audio_dir = "audio_files"
        os.makedirs(self.audio_dir, exist_ok=True)

    async def synthesize(self, text: str, language: str, voice: str) -> SynthesisResponse:
        """
        Convierte texto a voz con Azure Speech y guarda el audio como mp3
        usando el ID único (result_id) que devuelve Azure.
        """
        if not self.speech_key:
            raise ValueError("Falta configurar AZURE_API_KEY en el entorno")

        speech_config = speechsdk.SpeechConfig(
            subscription=self.speech_key,
            region=self.speech_region
        )

        # Validación de voz
        available_voices = self.voices_by_language.get(language[:2], [])
        if voice not in available_voices:
            voice = available_voices[0] if available_voices else "en-US-BrandonMultilingualNeural"

        speech_config.speech_synthesis_voice_name = voice

        # Generador de voz
        synthesizer = speechsdk.SpeechSynthesizer(
            speech_config=speech_config,
            audio_config=None  # Primero en memoria
        )

        result = synthesizer.speak_text_async(text).get()

        if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
            # Usar el ID único de Azure
            file_id = result.result_id
            file_name = f"{file_id}.mp3"
            file_path = os.path.join(self.audio_dir, file_name)

            # Guardar el audio en archivo
            with open(file_path, "wb") as f:
                f.write(result.audio_data)

            return SynthesisResponse(
                audio_data=file_path,
                language=language,
                voice=voice,
                sample_rate=22050
            )
        else:
            raise Exception(f"Error en síntesis: {result.reason}")

    async def get_available_voices(self) -> VoicesResponse:
        """
        Devuelve las voces disponibles configuradas
        """
        return VoicesResponse(
            languages=self.voices_by_language,
            default={lang: voices[0] for lang, voices in self.voices_by_language.items()},
        )
