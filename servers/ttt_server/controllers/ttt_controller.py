from fastapi import HTTPException
from models.ttt_models import TextRequest, TextResponse
from services.ttt_service import TTTService

class TTTController:
    def __init__(self):
        self.ttt_service = TTTService()
    
    async def process_text(self, request: TextRequest) -> TextResponse:
        """
        Controlador para el procesamiento de texto
        """
        if not request.text:
            raise HTTPException(status_code=400, detail="Text is required")
        
        if len(request.text) > 5000:
            raise HTTPException(status_code=400, detail="Text too long (max 5000 characters)")
        
        valid_tasks = ["translate", "summarize", "analyze"]
        if request.task not in valid_tasks:
            raise HTTPException(status_code=400, detail=f"Invalid task. Must be one of: {valid_tasks}")
        
        try:
            result = await self.ttt_service.translateAzure(
                text=request.text,
                source_language=request.source_language,
                target_language=request.target_language,
            )
            return result
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Text processing failed: {str(e)}")
    
    def get_available_tasks(self):
        try:
            return self.ttt_service.get_available_tasks()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to get tasks: {str(e)}")
    
    def get_supported_languages(self):
        try:
            return self.ttt_service.get_supported_languages()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to get languages: {str(e)}")
