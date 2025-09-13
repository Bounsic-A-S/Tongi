from pydantic import BaseModel, Field
from typing import Dict, List


class SynthesisRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=2000)
    language: str = Field(default="en-US")
    voice: str = Field(default="BrandonMultilingualNeural")

    class Config:
        schema_extra = {
            "example": {
                "text": "Hola, esto es una prueba de síntesis.",
                "language": "es",
                "voice": "default",
            }
        }


class SynthesisResponse(BaseModel):
    audio_data: str
    language: str
    voice: str
    sample_rate: int

    class Config:
        schema_extra = {
            "example": {
                "audio_data": "<base64>",
                "language": "es",
                "voice": "default",
                "sample_rate": 22050,
            }
        }


class VoicesResponse(BaseModel):
    languages: Dict[str, List[str]]
    default: Dict[str, str]


