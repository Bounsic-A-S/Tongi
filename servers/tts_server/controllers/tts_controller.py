from fastapi import HTTPException
from models.tts_models import SynthesisRequest, SynthesisResponse, VoicesResponse
from services.tts_service import TTSService
import os


class TTSController:
    def __init__(self):
        self.tts_service = TTSService()
        self.base_url = os.getenv("BASE_URL", "https://tts-server-app.bravefield-d0689482.eastus.azurecontainerapps.io")  # Para formar URLs completas de audio

    # --- Selecciona la voz correcta ---
    async def pick_voice(self, language: str, voice: str = None) -> str:
        available_voices = await self.tts_service.get_available_voices()
        voices_for_lang = available_voices.languages.get(language, [])

        if not voices_for_lang:
            # No hay voces para este idioma, usar Jenny por defecto
            return "en-US-JennyMultilingualNeural"

        if voice in voices_for_lang:
            return voice

        # Si la voz no es válida o no se especificó, usar la primera disponible
        return available_voices.default.get(language, voices_for_lang[0])

    # --- Endpoint de síntesis ---
    async def synthesize(self, request: SynthesisRequest) -> SynthesisResponse:
        if not request.text:
            raise HTTPException(status_code=400, detail="Text is required")

        try:
            voice_id = await self.pick_voice(request.language, request.voice)
            result = await self.tts_service.synthesize(
                text=request.text,
                language=request.language,
                voice=voice_id
            )

            # Formatear la URL completa para que el frontend pueda reproducirlo
            audio_url = f"{self.base_url}{result.audio_data}"

            return SynthesisResponse(
                audio_data=audio_url,
                language=result.language,
                voice=result.voice,
                sample_rate=result.sample_rate
            )

        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Synthesis failed: {str(e)}")

    # --- Endpoint de voces disponibles ---
    async def get_available_voices(self):
        try:
            voices_response: VoicesResponse = await self.tts_service.get_available_voices()
            return voices_response.dict()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to get voices: {str(e)}")
