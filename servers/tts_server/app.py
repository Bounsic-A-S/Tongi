from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from controllers.tts_controller import TTSController
from models.tts_models import SynthesisRequest

app = FastAPI(title="TTS Server - Text to Speech API")

# Habilitar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

tts_controller = TTSController()


@app.get("/")
async def root():
    return {"message": "TTS Server - Text to Speech API"}


@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "TTS"}


@app.post("/synthesize")
async def synthesize_speech(request: SynthesisRequest):
    """
    Endpoint para sintetizar voz desde texto
    """
    result = await tts_controller.synthesize(request)
    return {
        "audio_data": result.audio_data,
        "language": result.language,
        "voice": result.voice,
        "sample_rate": 22050,
    }


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
