from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from controllers.ttt_controller import TTTController
from models.ttt_models import TextRequest

app = FastAPI(title="TTT Server - Text to Text API")

# Habilitar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

ttt_controller = TTTController()


@app.get("/")
async def root():
    return {"message": "TTT Server - Text to Text API"}


@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "TTT"}


@app.post("/process")
async def process_text(request: TextRequest):
    """
    Endpoint para procesar texto (traducción, resumen, análisis)
    """
    result = await ttt_controller.process_text(request)
    return {
        "result": result.result,
        "source_language": result.source_language,
        "target_language": result.target_language,
        "task": result.task,
        "confidence": result.confidence
    }


@app.get("/tasks")
def get_available_tasks():
    """
    Obtener tareas disponibles
    """
    return ttt_controller.get_available_tasks()


@app.get("/languages")
def get_supported_languages():
    """
    Obtener idiomas soportados
    """
    return ttt_controller.get_supported_languages()
