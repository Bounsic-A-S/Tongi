from ..models.ttt_models import TextResponse, TaskInfo, LanguageInfo, LanguagesResponse

class TTTService:
    def __init__(self):
        self.supported_languages = {
            "es": {"name": "Español", "supported": True},
            "en": {"name": "English", "supported": True},
            "fr": {"name": "Français", "supported": True},
            "de": {"name": "Deutsch", "supported": True},
            "it": {"name": "Italiano", "supported": True},
            "pt": {"name": "Português", "supported": True}
        }
        
        self.available_tasks = [
            {"id": "translate", "name": "Traducción", "description": "Traducir texto entre idiomas"},
            {"id": "summarize", "name": "Resumen", "description": "Generar resumen del texto"},
            {"id": "analyze", "name": "Análisis", "description": "Analizar contenido del texto"}
        ]
    
    async def process_text(self, text: str, source_language: str, target_language: str, task: str) -> TextResponse:
        """
        Servicio para procesar texto según la tarea especificada
        """
        # Simulación de procesamiento de texto
        # En un caso real, aquí se integraría con servicios de IA como OpenAI, Google Translate, etc.
        
        if task == "translate":
            # Simular traducción
            translations = {
                ("es", "en"): f"Translated to English: {text}",
                ("en", "es"): f"Traducido al español: {text}",
                ("es", "fr"): f"Traduit en français: {text}",
                ("en", "fr"): f"Traduit en français: {text}",
                ("es", "de"): f"Auf Deutsch übersetzt: {text}",
                ("en", "de"): f"Auf Deutsch übersetzt: {text}"
            }
            
            result = translations.get((source_language, target_language), f"Translated: {text}")
            
        elif task == "summarize":
            # Simular resumen
            words = text.split()
            if len(words) > 10:
                summary_words = words[:10]
                result = f"Resumen: {' '.join(summary_words)}..."
            else:
                result = f"Resumen: {text}"
                
        elif task == "analyze":
            # Simular análisis
            char_count = len(text)
            word_count = len(text.split())
            result = f"Análisis: El texto contiene {char_count} caracteres y {word_count} palabras"
            
        else:
            result = f"Procesado: {text}"
        
        return TextResponse(
            result=result,
            source_language=source_language,
            target_language=target_language,
            task=task,
            confidence=0.92
        )
    
    async def get_available_tasks(self):
        """
        Obtener tareas disponibles
        """
        tasks = [
            TaskInfo(
                id=task["id"],
                name=task["name"],
                description=task["description"]
            )
            for task in self.available_tasks
        ]
        
        return {"tasks": tasks}
    
    async def get_supported_languages(self) -> LanguagesResponse:
        """
        Obtener idiomas soportados
        """
        languages = [
            LanguageInfo(
                code=code,
                name=info["name"],
                supported=info["supported"]
            )
            for code, info in self.supported_languages.items()
        ]
        
        return LanguagesResponse(
            languages=languages,
            default_source="es",
            default_target="en"
        )
