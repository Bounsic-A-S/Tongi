from fastapi import HTTPException
from models.stt_models import AudioRequest, TranscriptionResponse
from services.stt_service import STTService

class STTController:
    def __init__(self):
        self.stt_service = STTService()
    
    async def transcribe_audio(self, request: AudioRequest) -> TranscriptionResponse:
        """
        Controlador para la transcripción de audio
        """
        if not request.audio_data:
            raise HTTPException(status_code=400, detail="Audio data is required")
        try:
            result = await self.stt_service.transcribe(request.audio_data, request.language)
            return result
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")
    
    async def get_supported_languages(self):
        """
        Controlador para obtener idiomas soportados
        """
        try:
            return await self.stt_service.get_supported_languages()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to get languages: {str(e)}")
