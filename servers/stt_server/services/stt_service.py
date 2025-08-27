from ..models.stt_models import TranscriptionResponse, LanguageInfo, LanguagesResponse

class STTService:
    def __init__(self):
        self.supported_languages = {
            "es": {"name": "Español", "supported": True},
            "en": {"name": "English", "supported": True},
            "fr": {"name": "Français", "supported": True},
            "de": {"name": "Deutsch", "supported": True}
        }
    
    async def transcribe(self, audio_data: str, language: str) -> TranscriptionResponse:
        """
        Servicio para transcribir audio a texto
        """
        # Simulación de transcripción
        # En un caso real, aquí se integraría con un servicio de STT como Google Speech-to-Text
        
        mock_transcriptions = {
            "es": "Este es un texto de ejemplo transcrito del audio en español",
            "en": "This is an example text transcribed from audio in English",
            "fr": "Ceci est un exemple de texte transcrit de l'audio en français",
            "de": "Dies ist ein Beispieltext, der aus Audio auf Deutsch transkribiert wurde"
        }
        
        text = mock_transcriptions.get(language, mock_transcriptions["es"])
        confidence = 0.95
        
        return TranscriptionResponse(
            text=text,
            confidence=confidence,
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
