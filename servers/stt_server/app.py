from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from controllers.stt_controller import STTController
from models.stt_models import AudioRequest

app = FastAPI(title="STT Server - Speech to Text API")

# Habilitar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

stt_controller = STTController()


@app.get("/")
async def root():
    return {"message": "STT Server - Speech to Text API"}


@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "STT"}


@app.post("/transcribe")
async def transcribe_audio(request: AudioRequest):
    """
    Endpoint para transcribir audio a texto
    """
    result = await stt_controller.transcribe_audio(request)
    return {
        "text": result.text,
        "confidence": 0.95,
        "language": result.language
    }


@app.get("/languages")
async def get_supported_languages():
    """
    Obtener idiomas soportados
    """
    result = await stt_controller.get_supported_languages()
    return {
        "languages": [lang.code for lang in result.languages],
        "default": result.default
    }
