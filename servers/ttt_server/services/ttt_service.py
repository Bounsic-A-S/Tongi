from models.ttt_models import TextResponse, TaskInfo, LanguageInfo, LanguagesResponse, LanguageEnum
import requests
from typing import Optional
import os

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
        api_key = os.getenv("AZURE_API_KEY")
        endpoint = os.getenv("AZURE_ENDPOINT")
        location = os.getenv("AZURE_LOCATION")
        project_name = os.getenv("AZURE_PROJECT_NAME")
        deployment_name = os.getenv("AZURE_DEPLOYMENT_NAME")
    
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

    async def translateAzure(self, text: str, source_language: Optional[str], target_language: str) -> TextResponse:
        api_key = os.getenv("AZURE_API_KEY")
        endpoint = os.getenv("AZURE_ENDPOINT")
        location = os.getenv("AZURE_LOCATION")

        path = "/translate?api-version=3.0"
        params = f"&to={target_language.value}"  # <- usar .value

        # Solo agregar 'from' si viene definido y no es 'auto'
        if source_language and source_language != "auto":
            params += f"&from={source_language}"

        url = endpoint + path + params

        headers = {
            "Ocp-Apim-Subscription-Key": api_key,
            "Ocp-Apim-Subscription-Region": location,
            "Content-type": "application/json"
        }

        body = [{"text": text}]

        try:
            response = requests.post(url, headers=headers, json=body)
            response.raise_for_status()
            result = response.json()
            print("result", result)
            response = TextResponse(
                result=result[0]["translations"][0]["text"],
                source_language=result[0]["detectedLanguage"]["language"],
                target_language=target_language,
                task="translate",
                confidence=result[0]["detectedLanguage"]["score"]
            )
            return response

        except Exception as e:
            return f"Error en traducción: {str(e)}"

