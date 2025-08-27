from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="STT Server", description="Speech-to-Text API Server", version="1.0.0")

class AudioRequest(BaseModel):
    audio_data: str
    language: str = "es"

class TranscriptionResponse(BaseModel):
    text: str
    confidence: float
    language: str

@app.get("/")
async def root():
    return {"message": "STT Server - Speech to Text API"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "STT"}

@app.post("/transcribe", response_model=TranscriptionResponse)
async def transcribe_audio(request: AudioRequest):
    """
    Endpoint para transcribir audio a texto
    """
    try:
        # Simulación de transcripción
        # En un caso real, aquí se procesaría el audio
        mock_transcription = "Este es un texto de ejemplo transcrito del audio"
        
        return TranscriptionResponse(
            text=mock_transcription,
            confidence=0.95,
            language=request.language
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/languages")
async def get_supported_languages():
    """
    Obtener idiomas soportados
    """
    return {
        "languages": ["es", "en", "fr", "de"],
        "default": "es"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
