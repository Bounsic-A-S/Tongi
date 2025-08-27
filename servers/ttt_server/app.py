from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="TTT Server", description="Text-to-Text API Server", version="1.0.0")

class TextRequest(BaseModel):
    text: str
    source_language: str = "es"
    target_language: str = "en"
    task: str = "translate"  # translate, summarize, analyze

class TextResponse(BaseModel):
    result: str
    source_language: str
    target_language: str
    task: str
    confidence: float

@app.get("/")
async def root():
    return {"message": "TTT Server - Text to Text API"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "TTT"}

@app.post("/process", response_model=TextResponse)
async def process_text(request: TextRequest):
    """
    Endpoint para procesar texto (traducción, resumen, análisis)
    """
    try:
        # Simulación de procesamiento de texto
        # En un caso real, aquí se integraría con servicios de IA
        
        if request.task == "translate":
            mock_result = f"Translated text: {request.text}"
        elif request.task == "summarize":
            mock_result = f"Summary: {request.text[:50]}..."
        elif request.task == "analyze":
            mock_result = f"Analysis: Text contains {len(request.text)} characters"
        else:
            mock_result = f"Processed: {request.text}"
        
        return TextResponse(
            result=mock_result,
            source_language=request.source_language,
            target_language=request.target_language,
            task=request.task,
            confidence=0.92
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/tasks")
async def get_available_tasks():
    """
    Obtener tareas disponibles
    """
    return {
        "tasks": [
            {"id": "translate", "name": "Traducción", "description": "Traducir texto entre idiomas"},
            {"id": "summarize", "name": "Resumen", "description": "Generar resumen del texto"},
            {"id": "analyze", "name": "Análisis", "description": "Analizar contenido del texto"}
        ]
    }

@app.get("/languages")
async def get_supported_languages():
    """
    Obtener idiomas soportados
    """
    return {
        "languages": ["es", "en", "fr", "de", "it", "pt"],
        "default_source": "es",
        "default_target": "en"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8003)
