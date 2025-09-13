from models.stt_models import TranscriptionResponse, LanguageInfo, LanguagesResponse, TranslationResponse
import os
import azure.cognitiveservices.speech as speechsdk

class STTService:
    def __init__(self):
        self.supported_languages = {
            "es": {"name": "Español", "supported": True},
            "en": {"name": "English", "supported": True},
            "fr": {"name": "Français", "supported": True},
            "de": {"name": "Deutsch", "supported": True}
        }
    
    async def transcribe(self, audio_data: str, language: str) -> TranslationResponse:
        """
        Servicio para transcribir audio a texto
        """
        api_key = os.getenv("AZURE_API_KEY")
        location = os.getenv("AZURE_LOCATION")

        speech_config = speechsdk.translation.SpeechTranslationConfig(subscription=api_key, region=location)
        speech_config.add_target_language(language)

        auto_translate_config = speechsdk.languageconfig.AutoDetectSourceLanguageConfig(
            languages=["en-US", "es-ES", "fr-FR", "de-DE"]
        )

        pathAudio = os.getcwd()
        folderAudio= "/audio_files/"
        os.makedirs(pathAudio + folderAudio, exist_ok=True)     
        full_path = pathAudio + folderAudio
        audio_file_path = os.path.join(full_path, audio_data)

        audioInput = speechsdk.AudioConfig(filename=audio_file_path)
        
        speech_transcriber = speechsdk.translation.TranslationRecognizer(
            translation_config=speech_config, 
            audio_config=audioInput,
            auto_detect_source_language_config= auto_translate_config)

        result = speech_transcriber.recognize_once_async().get()
        print(result)

        if result.reason == speechsdk.ResultReason.TranslatedSpeech:
            detected_lang = result.properties[
                speechsdk.PropertyId.SpeechServiceConnection_AutoDetectSourceLanguageResult
            ]
            return TranslationResponse(
                detected_language=detected_lang,
                original_text=result.text,
                translation=result.translations.get(language, "")
            )

        elif result.reason == speechsdk.ResultReason.NoMatch:
            return TranslationResponse(
                detected_language="unknown",
                original_text="",
                translation=f"No se reconoció nada en el audio para {language}"
            )

        else:
            cancellation_details = result.cancellation_details
            return TranslationResponse(
                detected_language="error",
            original_text="",
            translation=f"Error: {cancellation_details.reason}, {cancellation_details.error_details}"
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
