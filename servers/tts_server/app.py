from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="TTS Server", description="Text-to-Speech API Server", version="1.0.0")


class SynthesisRequest(BaseModel):
    text: str
    language: str = "es"
    voice: str = "default"


class SynthesisResponse(BaseModel):
    audio_data: str  # base64
    language: str
    voice: str
    sample_rate: int


@app.get("/")
async def root():
    return {"message": "TTS Server - Text to Speech API"}


@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "TTS"}


@app.post("/synthesize", response_model=SynthesisResponse)
async def synthesize_speech(request: SynthesisRequest):
    """
    Endpoint para sintetizar voz desde texto
    """
    try:
        if not request.text:
            raise HTTPException(status_code=400, detail="Text is required")

        # Simulación de síntesis: audio base64 ficticio
        mock_audio_b64 = "UklGRiQAAABXQVZFZm10IBAAAAABAAEAESsAACJWAAACABAAZGF0YQAAAA=="

        return SynthesisResponse(
            audio_data=mock_audio_b64,
            language=request.language,
            voice=request.voice,
            sample_rate=22050,
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/voices")
async def get_available_voices():
    """
    Obtener voces disponibles por idioma
    """
    return {
        "languages": {
            "es": ["default", "female_1", "male_1"],
            "en": ["default", "female_1", "male_1"],
        },
        "default": {"es": "default", "en": "default"},
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8002)


