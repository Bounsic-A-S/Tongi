from fastapi import HTTPException
from ..models.ttt_models import TextRequest, TextResponse
from ..services.ttt_service import TTTService

class TTTController:
    def __init__(self):
        self.ttt_service = TTTService()
    
    async def process_text(self, request: TextRequest) -> TextResponse:
        """
        Controlador para el procesamiento de texto
        """
        try:
            # Validar entrada
            if not request.text:
                raise HTTPException(status_code=400, detail="Text is required")
            
            if len(request.text) > 5000:
                raise HTTPException(status_code=400, detail="Text too long (max 5000 characters)")
            
            # Validar tarea
            valid_tasks = ["translate", "summarize", "analyze"]
            if request.task not in valid_tasks:
                raise HTTPException(status_code=400, detail=f"Invalid task. Must be one of: {valid_tasks}")
            
            # Procesar texto
            result = await self.ttt_service.process_text(
                request.text,
                request.source_language,
                request.target_language,
                request.task
            )
            
            return result
            
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Text processing failed: {str(e)}")
    
    async def get_available_tasks(self):
        """
        Controlador para obtener tareas disponibles
        """
        try:
            return await self.ttt_service.get_available_tasks()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to get tasks: {str(e)}")
    
    async def get_supported_languages(self):
        """
        Controlador para obtener idiomas soportados
        """
        try:
            return await self.ttt_service.get_supported_languages()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to get languages: {str(e)}")
