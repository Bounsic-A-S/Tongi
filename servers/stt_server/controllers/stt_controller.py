from fastapi import HTTPException, UploadFile
from models.stt_models import AudioRequest, TranscriptionResponse
from services.stt_service import STTService
import tempfile
import os

class STTController:
    def __init__(self):
        self.stt_service = STTService()
    
    async def transcribe_audio_file(self, file: UploadFile, language: str) -> TranscriptionResponse:
        """Transcripción desde archivo binario"""
        try:
            allowed_extensions = (".m4a", ".mp3", ".wav")
            filename_lower = file.filename.lower()
            if not filename_lower.endswith(allowed_extensions):
                raise HTTPException(
                    status_code=400,
                    detail=f"Solo se permiten archivos con extensión {', '.join(allowed_extensions)}"
                )
            print(filename_lower)
            # Usar la extensión original del archivo para el temporal
            suffix = filename_lower[filename_lower.rfind("."):]
            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp_audio:
                contents = await file.read()
                temp_audio.write(contents)
                temp_path = temp_audio.name

            # Lógica real de transcripción
            result = await self.stt_service.transcribe(temp_path, language)

            # Eliminar archivo temporal
            os.remove(temp_path)

            return result
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"File transcription failed: {str(e)}")

    async def translate_audio_file(self, 
                                   file: UploadFile, 
                                   source_language: str, 
                                   target_language: str) -> TranscriptionResponse:
        """
        Transcribe y traduce un archivo de audio del idioma origen 
        al idioma destino usando Azure Translation.
        """
        try:
            allowed_extensions = (".m4a", ".mp3", ".wav")
            filename_lower = file.filename.lower()
            if not filename_lower.endswith(allowed_extensions):
                raise HTTPException(
                    status_code=400,
                    detail=f"Solo se permiten archivos con extensión {', '.join(allowed_extensions)}"
                )

            # 1. Guardar el archivo temporalmente
            suffix = filename_lower[filename_lower.rfind("."):]
            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp_audio:
                contents = await file.read()
                temp_audio.write(contents)
                temp_path = temp_audio.name

            # 2. Lógica real de transcripción Y TRADUCCIÓN
            result = await self.stt_service.translate_audio(
                audio_file=temp_path,
                source_language=source_language,
                target_language=target_language
            )

            # 3. Eliminar archivo temporal
            os.remove(temp_path)

            return result
        except HTTPException:
            # Si es una excepción HTTP ya definida (ej: error 400), la relanzamos.
            raise
        except FileNotFoundError as e:
            # Manejar específicamente si el servicio no encuentra el archivo (aunque lo acabamos de guardar)
            raise HTTPException(status_code=500, detail=f"Internal file error: {str(e)}")
        except Exception as e:
            # Manejar cualquier otro error del servicio de Azure o interno
            raise HTTPException(status_code=500, detail=f"File translation failed: {str(e)}")


    async def get_supported_languages(self):
        """Controlador para obtener idiomas soportados"""
        try:
            return await self.stt_service.get_supported_languages()
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to get languages: {str(e)}")

