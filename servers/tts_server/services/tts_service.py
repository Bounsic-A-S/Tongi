from ..models.tts_models import SynthesisResponse, VoicesResponse


class TTSService:
    def __init__(self):
        self.voices_by_language = {
            "es": ["default", "female_1", "male_1"],
            "en": ["default", "female_1", "male_1"],
        }

    async def synthesize(self, text: str, language: str, voice: str) -> SynthesisResponse:
        # Simulación: devolver audio base64 constante
        mock_audio_b64 = "UklGRiQAAABXQVZFZm10IBAAAAABAAEAESsAACJWAAACABAAZGF0YQAAAA=="
        if language not in self.voices_by_language:
            language = "es"
        if voice not in self.voices_by_language.get(language, []):
            voice = "default"

        return SynthesisResponse(
            audio_data=mock_audio_b64,
            language=language,
            voice=voice,
            sample_rate=22050,
        )

    async def get_available_voices(self) -> VoicesResponse:
        return VoicesResponse(
            languages=self.voices_by_language,
            default={lang: "default" for lang in self.voices_by_language.keys()},
        )


