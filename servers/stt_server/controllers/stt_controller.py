from flask import abort, jsonify
from models.stt_models import AudioRequest, TranscriptionResponse, TranslationResponse
from services.stt_service import STTService

class STTController:
    def __init__(self):
        self.stt_service = STTService()
    
    async def transcribe_audio(self, request: AudioRequest) -> TranslationResponse:
        """
        Controlador para la transcripción de audio
        """
        try:
            audioData = request.get("audio_data")
            language = request.get("language")
            print(language)
            print(audioData)
            # Validar entrada
            if not audioData:
                abort(400, description="Audio data is required")

            if not language:
                language = "en"
            
            # Procesar transcripción
            result = await self.stt_service.transcribe(audioData, language)

            return result
            
        except Exception as e:
            abort(500, description=f"Transcription failed: {str(e)}")
    
    async def get_supported_languages(self):
        """
        Controlador para obtener idiomas soportados
        """
        try:
            return await self.stt_service.get_supported_languages()
        except Exception as e:
            abort(500, description=f"Failed to get languages: {str(e)}")
