import os
import azure.cognitiveservices.speech as speechsdk
from models.stt_models import TranscriptionResponse, LanguageInfo, LanguagesResponse


class STTService:
    def __init__(self):
        self.supported_languages = {
            "es": {"name": "Español", "supported": True},
            "en": {"name": "English", "supported": True},
            "fr": {"name": "Français", "supported": True},
            "de": {"name": "Deutsch", "supported": True}
        }
        # Configuración con Azure Speech
        self.speech_key = os.getenv("AZURE_API_KEY")
        self.speech_region = os.getenv("AZURE_LOCATION", "eastus")  # cambia según tu recurso

    async def transcribe_auto_language(self, audio_file: str) -> TranscriptionResponse:
        """
        Transcribe un archivo de audio a texto usando Azure Speech-to-Text
        detectando automáticamente el idioma.
        :param audio_file: Nombre del archivo en la carpeta audio_files
        """
        file_path = os.path.join("audio_files", audio_file)
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"El archivo {file_path} no existe.")

        # Configuración de Speech
        speech_config = speechsdk.SpeechConfig(
            subscription=self.speech_key,
            region=self.speech_region
        )

        # Configuración de detección automática de idioma
        auto_detect_source_language_config = speechsdk.languageconfig.AutoDetectSourceLanguageConfig(
            languages=list(self.supported_languages.keys())  # Idiomas a detectar
        )

        audio_config = speechsdk.AudioConfig(filename=file_path)
        recognizer = speechsdk.SpeechRecognizer(
            speech_config=speech_config,
            auto_detect_source_language_config=auto_detect_source_language_config,
            audio_config=audio_config
        )

        result = await recognizer.recognize_once_async()

        if result.reason == speechsdk.ResultReason.RecognizedSpeech:
            detected_language = result.properties.get(
                speechsdk.PropertyId.SpeechServiceConnection_AutoDetectSourceLanguageResult
            )
            return TranscriptionResponse(
                text=result.text,
                confidence=0.95,
                language=detected_language
            )
        else:
            return TranscriptionResponse(
                text="No se pudo transcribir el audio.",
                confidence=0.0,
                language=None
            )

    async def get_supported_languages(self) -> LanguagesResponse:
        """
        Obtener idiomas soportados
        """
        languages = [
            LanguageInfo(
                code=code,
                name=info["name"],
                supported=info["supported"]
            )
            for code, info in self.supported_languages.items()
        ]
        
        return LanguagesResponse(
            languages=languages,
            default="es"
        )
