from pydantic import BaseModel, Field
from typing import List

class TextRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=5000)
    source_language: str = Field(default="es", regex="^[a-z]{2}$")
    target_language: str = Field(default="en", regex="^[a-z]{2}$")
    task: str = Field(default="translate", regex="^(translate|summarize|analyze)$")
    
    class Config:
        schema_extra = {
            "example": {
                "text": "Hola mundo, este es un texto de prueba para procesar",
                "source_language": "es",
                "target_language": "en",
                "task": "translate"
            }
        }

class TextResponse(BaseModel):
    result: str
    source_language: str
    target_language: str
    task: str
    confidence: float
    
    class Config:
        schema_extra = {
            "example": {
                "result": "Hello world, this is a test text to process",
                "source_language": "es",
                "target_language": "en",
                "task": "translate",
                "confidence": 0.92
            }
        }

class TaskInfo(BaseModel):
    id: str
    name: str
    description: str

class TasksResponse(BaseModel):
    tasks: List[TaskInfo]

class LanguageInfo(BaseModel):
    code: str
    name: str
    supported: bool

class LanguagesResponse(BaseModel):
    languages: List[LanguageInfo]
    default_source: str
    default_target: str
