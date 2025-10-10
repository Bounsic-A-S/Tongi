import os
import azure.cognitiveservices.speech as speechsdk
from models.tts_models import SynthesisResponse, VoicesResponse
import json
import base64
import threading
import time


class TTSService:
    def __init__(self):
        self.speech_key = os.getenv("AZURE_API_KEY")
        self.speech_region = os.getenv("AZURE_LOCATION", "eastus")
        self.voices_data = self._load_voices_config()
        self.audio_dir = "/tmp/audio_files"  # carpeta temporal
        os.makedirs(self.audio_dir, exist_ok=True)
        # Inicia el hilo de limpieza
        threading.Thread(target=self.cleanup_loop, daemon=True).start()
    
    def _load_voices_config(self):
        config_path = os.getenv("AZURE_VOICES_FILE", "config/azure_voices.json")
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            print(f"[TTSService] ✅ Voces cargadas correctamente desde {config_path}")
            return data
        except Exception as e:
            print(f"[TTSService] ⚠️ Error cargando {config_path}: {e}")
            return {"language_voice_map": {}, "voice_categories": {}}

    # --- Obtiene las voces disponibles para un idioma ---
    def get_voices_for_language(self, language_code: str):
        lang_data = self.voices_data.get("language_voice_map", {}).get(language_code, {})
        native_voices = lang_data.get("native_voices", [])
        other_voices = lang_data.get("other_multilingual_voices", [])
        return native_voices + other_voices

    # --- Devuelve información completa de una voz ---
    def get_voice_info(self, voice_id: str):
        for category in self.voices_data.get("voice_categories", {}).values():
            for voice in category.get("voices", []):
                if voice["id"] == voice_id:
                    return voice
        return None

    def cleanup_loop(self):
        while True:
            now = time.time()
            max_age = 5 * 60  # 5 minutos
            for file in os.listdir(self.audio_dir):
                path = os.path.join(self.audio_dir, file)
                if os.path.isfile(path):
                    if now - os.path.getmtime(path) > max_age:
                        try:
                            os.remove(path)
                            print(f"🧹 Borrado temporal: {file}")
                        except Exception as e:
                            print(f"⚠️ No se pudo borrar {file}: {e}")
                elif os.path.isdir(path):
                    try:
                        # Borrar contenido del directorio
                        for subfile in os.listdir(path):
                            os.remove(os.path.join(path, subfile))
                        os.rmdir(path)
                        print(f"🧹 Borrado temporal de directorio: {file}")
                    except Exception as e:
                        print(f"⚠️ No se pudo borrar directorio {file}: {e}")
            time.sleep(120)  # Ejecuta cada 2 minuto



    async def synthesize(self, text: str, language: str, voice: str) -> SynthesisResponse:
        """
        Convierte texto a voz con Azure Speech y guarda el audio como mp3
        usando el ID único (result_id) que devuelve Azure.
        """
        if not self.speech_key:
            raise ValueError("Falta configurar AZURE_API_KEY en el entorno")

        available_voices = self.get_voices_for_language(language)
        if not available_voices:
            print(f"[TTSService] ⚠️ No hay voces configuradas para {language}, usando Jenny.")
            voice_id = "en-US-JennyMultilingualNeural"
        elif voice not in available_voices:
            print(f"[TTSService] ⚠️ Voz {voice} no válida para {language}, usando la primera disponible.")
            voice_id = available_voices[0]
        else:
            voice_id = voice

        speech_config = speechsdk.SpeechConfig(
            subscription=self.speech_key,
            region=self.speech_region
        )
        speech_config.speech_synthesis_voice_name = voice_id

        # Generador de voz
        synthesizer = speechsdk.SpeechSynthesizer(
            speech_config=speech_config,
            audio_config=None  # Primero en memoria
        )

        result = synthesizer.speak_text_async(text).get()

        if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
            # Usar el ID único de Azure
            file_id = result.result_id
            file_name = f"{file_id}.wav"
            file_path = os.path.join(self.audio_dir, file_name)

            # Guardar el audio en archivo
            with open(file_path, "wb") as f:
                f.write(result.audio_data)

            return SynthesisResponse(
                audio_data = f"/audio/{file_name}",
                language=language,
                voice=voice,
                sample_rate=22050
            )
        else:
            raise Exception(f"Error en síntesis: {result.reason}")

    async def get_available_voices(self) -> VoicesResponse:
        lang_map = self.voices_data.get("language_voice_map", {})
        languages = {
            lang: data.get("native_voices", []) + data.get("other_multilingual_voices", [])
            for lang, data in lang_map.items()
        }
        defaults = {
            lang: (data.get("native_voices", []) + data.get("other_multilingual_voices", []))[0]
            if (data.get("native_voices", []) or data.get("other_multilingual_voices", [])) else None
            for lang, data in lang_map.items()
        }

        return VoicesResponse(languages=languages, default=defaults)
