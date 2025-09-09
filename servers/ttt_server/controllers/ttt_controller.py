from flask import abort, jsonify
from models.ttt_models import TextRequest, TextResponse
from services.ttt_service import TTTService

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
                abort(400, description="Text is required")
            
            if len(request.text) > 5000:
                abort(400, description="Text too long (max 5000 characters)")
            
            # Validar tarea
            valid_tasks = ["translate", "summarize", "analyze"]
            if request.task not in valid_tasks:
                abort(400, description=f"Invalid task. Must be one of: {valid_tasks}")
            
            
            
            # Procesar texto con el servicio
            result = await self.ttt_service.translateAzure(
                text=request.text,
                source_language=request.source_language,
                target_language=request.target_language,
            )
            
            return result
        
        except Exception as e:
            abort(500, description=f"Text processing failed: {str(e)}")
    
    def get_available_tasks(self):
        """
        Controlador para obtener tareas disponibles
        """
        try:
            return self.ttt_service.get_available_tasks()
        except Exception as e:
            abort(500, description=f"Failed to get tasks: {str(e)}")
    
    def get_supported_languages(self):
        """
        Controlador para obtener idiomas soportados
        """
        try:
            return self.ttt_service.get_supported_languages()
        except Exception as e:
            abort(500, description=f"Failed to get languages: {str(e)}")
