from pydantic import BaseModel, Field, validator
from typing import List, Optional, Literal
from enum import Enum

class LanguageEnum(str, Enum):
    en = "en"
    it = "it"
    fr = "fr"
    de = "de"
    es = "es"
    jp = "jp"

class TextRequest(BaseModel):
    text: str
    source_language: Optional[str] = None
    target_language: LanguageEnum = Field(default="en")
    task: Literal["translate", "summarize", "analyze"] = Field(default="translate")

    @validator("source_language")
    def validate_source_language(cls, v):
        if v is None or v == "":
            return None  # dejar vacío para detección automática
        if not v.isalpha() or len(v) > 2:
            raise ValueError("source_language must be 1 or 2 letters")
        return v.lower()
    
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
    task: Optional[str] = None
    confidence: Optional[float] = None
    
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
