from flask import abort
from models.tts_models import SynthesisRequest, SynthesisResponse
from services.tts_service import TTSService


class TTSController:
    def __init__(self):
        self.tts_service = TTSService()

    async def synthesize(self, request: SynthesisRequest):
        try:
            if not request.text:
                abort(400, description="Text is required")
            return await self.tts_service.synthesize(
                request.text, request.language, request.voice
            )
        except Exception as e:
            abort(500, description=f"Synthesis failed: {str(e)}")

    async def get_available_voices(self):
        try:
            return await self.tts_service.get_available_voices()
        except Exception as e:
            abort(status_code=500, detail=f"Failed to get voices: {str(e)}")


