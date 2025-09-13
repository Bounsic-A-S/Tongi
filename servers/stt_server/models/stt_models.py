from pydantic import BaseModel
from typing import List, Optional

class AudioRequest(BaseModel):
    audio_data: str
    language: str = "es"
    
    class Config:
        schema_extra = {
            "example": {
                "audio_data": "base64_encoded_audio_data",
                "language": "es"
            }
        }

class TranscriptionResponse(BaseModel):
    text: str
    confidence: float
    language: str
    
    class Config:
        schema_extra = {
            "example": {
                "text": "Este es un texto transcrito del audio",
                "confidence": 0.95,
                "language": "es"
            }
        }

class TranslationResponse(BaseModel):
    detected_language: str
    original_text: str
    translation: str
    
    class Config:
        schema_extra = {
            "example": {
                "detected_language": "en",
                "original_text": "This is a transcribed text from audio",
                "translation": "Este es un texto transcrito del audio"
            }
        }


class LanguageInfo(BaseModel):
    code: str
    name: str
    supported: bool

class LanguagesResponse(BaseModel):
    languages: List[LanguageInfo]
    default: str
