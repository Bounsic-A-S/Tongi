from flask import abort, jsonify
from ..models.tts_models import SynthesisRequest, SynthesisResponse
from ..services.tts_service import TTSService


class TTSController:
    def __init__(self):
        self.tts_service = TTSService()

    async def synthesize(self, request: SynthesisRequest) -> SynthesisResponse:
        try:
            if not request.text:
                abort(status_code=400, detail="Text is required")
            return await self.tts_service.synthesize(
                request.text, request.language, request.voice
            )
        except Exception as e:
            abort(status_code=500, detail=f"Synthesis failed: {str(e)}")

    async def get_available_voices(self):
        try:
            return await self.tts_service.get_available_voices()
        except Exception as e:
            abort(status_code=500, detail=f"Failed to get voices: {str(e)}")


