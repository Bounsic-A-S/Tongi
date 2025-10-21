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

    async def transcribe(self, audio_file: str, language: str) -> TranscriptionResponse:
        """
        Transcribe un archivo de audio a texto usando Azure Speech-to-Text
        :param audio_file: Nombre del archivo en la carpeta audio_files
        :param language: Código del idioma ("es", "en", etc.)
        """
        # Ruta real del archivo en tu servidor
        print("🔹 Iniciando transcripción")
        print(f"Archivo recibido: {audio_file}")
        print(f"Idioma: {language}")

        if not os.path.exists(audio_file):
            raise FileNotFoundError(f"El archivo {audio_file} no existe.")

        print("✅ Archivo encontrado, configurando Speech SDK")

        # Configuración de Speech
        speech_config = speechsdk.SpeechConfig(
            subscription=self.speech_key,
            region=self.speech_region
        )
        print(f"Azure key: {self.speech_key}, región: {self.speech_region}")

        speech_config.speech_recognition_language = language
        print(language)
        audio_config = speechsdk.AudioConfig(filename=audio_file)
        recognizer = speechsdk.SpeechRecognizer(
            speech_config=speech_config,
            audio_config=audio_config
        )

        print("✅ Reconocedor creado, enviando audio a Azure...")

        result = recognizer.recognize_once_async().get()

        print(f"🔹 Resultado raw de Azure: reason={result.reason}, texto='{result.text}'")

        if result.reason == speechsdk.ResultReason.RecognizedSpeech:
            print("✅ Audio transcrito correctamente")
            return TranscriptionResponse(
                text=result.text,
                confidence=0.95,
                language=language
            )
        elif result.reason == speechsdk.ResultReason.NoMatch:
            print(f"⚠️ No se pudo reconocer el audio: {result.no_match_details}")
        elif result.reason == speechsdk.ResultReason.Canceled:
            cancellation = speechsdk.CancellationDetails.from_result(result)
            print(f"❌ Transcripción cancelada: {cancellation.reason}, {cancellation.error_details}")
        else:
            print(f"⚠️ Resultado inesperado: {result.reason}")

        return TranscriptionResponse(
            text="No se pudo transcribir el audio.",
            confidence=0.0,
            language=language
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

    async def translate_audio(self, audio_file: str, source_language: str, target_language: str ) -> TranscriptionResponse:
        """
        Transcribe un archivo de audio del idioma origen y lo traduce 
        al idioma destino usando Azure Translation.
        """
        print("🔹 Iniciando traducción y transcripción.")
        print(f"Archivo: {audio_file}, Origen: {source_language}, Destino: {target_language}")

        if not os.path.exists(audio_file):
            raise FileNotFoundError(f"El archivo {audio_file} no existe.")

        print("✅ Archivo encontrado, configurando Translation SDK")

        # 1. Configuración de Speech/Translation
        # 🚨 CORRECCIÓN: Usar SpeechTranslationConfig 🚨
        translation_config = speechsdk.translation.SpeechTranslationConfig(
            subscription=self.speech_key,
            region=self.speech_region
        )

        # 2. Establecer el idioma de entrada (source_language)
        translation_config.speech_recognition_language = source_language 

        # 3. Establecer el idioma o idiomas de destino
        translation_config.add_target_language(target_language)

        # 4. Configuración del Audio
        audio_config = speechsdk.AudioConfig(filename=audio_file)
        
        # 5. Crear el TranslationRecognizer
        recognizer = speechsdk.translation.TranslationRecognizer(
            translation_config=translation_config,
            audio_config=audio_config
        )

        print("✅ Reconocedor de Traducción creado, enviando audio a Azure...")

        # El resultado es un TranslationRecognitionResult
        result = recognizer.recognize_once_async().get()

        if result.reason == speechsdk.ResultReason.TranslatedSpeech:
            
            transcription = result.text
            translation = result.translations[target_language]
            
            print(f"✅ Transcripción: {transcription}")
            print(f"✅ Traducción a {target_language}: {translation}")
            
            return TranscriptionResponse(
                text=translation, 
                confidence=0.95,
                language=target_language
            )
            
        elif result.reason == speechsdk.ResultReason.NoMatch:
            print(f"⚠️ No se pudo reconocer o traducir el audio: {result.no_match_details}")
        elif result.reason == speechsdk.ResultReason.Canceled:
            cancellation = speechsdk.CancellationDetails.from_result(result)
            print(f"❌ Traducción cancelada: {cancellation.reason}, {cancellation.error_details}")
        else:
            print(f"⚠️ Resultado inesperado: {result.reason}")

        return TranscriptionResponse(
            text="No se pudo traducir el audio.",
            confidence=0.0,
            language=target_language
        )
