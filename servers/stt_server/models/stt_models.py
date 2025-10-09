from pydantic import BaseModel
from typing import List, Optional

class AudioRequest(BaseModel):
    audio_data: str
    language: str = "es"
    
    class Config:
        json_schema_extra = {
            "example": {
                "audio_data": "base64_encoded_audio_data",
                "language": "es"
            }
        }


class AudioRequest1(BaseModel):
    audio_data: str
    
    class Config:
        json_schema_extra  = {
            "example": {
                "audio_data": "base64_encoded_audio_data",
            }
        }

class TranscriptionResponse(BaseModel):
    text: str
    confidence: float
    language: str
    
    class Config:
        json_schema_extra  = {
            "example": {
                "text": "Este es un texto transcrito del audio",
                "confidence": 0.95,
                "language": "es"
            }
        }

class LanguageInfo(BaseModel):
    code: str
    name: str
    supported: bool

class LanguagesResponse(BaseModel):
    languages: List[LanguageInfo]
    default: str
