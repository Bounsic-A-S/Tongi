from fastapi import FastAPI, UploadFile, File, Form
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
async def transcribe_audio(
    file: UploadFile = File(...),
    language: str = Form("es")
):
    """
    Endpoint para recibir un archivo de audio, transcribirlo y eliminarlo.
    """
    result = await stt_controller.transcribe_audio_file(file, language)
    return {
        "text": result.text,
        "confidence": result.confidence,
        "language": result.language
    }

@app.post("/transcribe/translate")
async def translate_audio(
    file: UploadFile = File(...),
    source_language: str = Form("es-ES"),
    target_language: str = Form("en-US")
):
    """
    Endpoint para recibir un archivo de audio, transcribirlo y eliminarlo.
    """
    result = await stt_controller.translate_audio_file(file, source_language, target_language)
    return {
        "text": result.text,
        "confidence": result.confidence,
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
