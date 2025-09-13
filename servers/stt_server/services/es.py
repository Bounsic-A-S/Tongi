async def transcribe(self, audio_data: str, target_language: str):
        api_key = os.getenv("AZURE_API_KEY")
        location = os.getenv("AZURE_LOCATION")

        translation_config = speechsdk.translation.SpeechTranslationConfig(
            subscription=api_key,
            region=location
        )

        # Idioma de salida (ej: "es-ES", "fr-FR", "it-IT")
        translation_config.add_target_language(target_language)

        # Auto detectar entre varios idiomas de entrada
        auto_detect_source_language_config = speechsdk.languageconfig.AutoDetectSourceLanguageConfig(
            languages=["en-US", "es-ES", "fr-FR", "it-IT", "de-DE"]
        )

        # Ruta del archivo de audio
        pathAudio = os.getcwd()
        folderAudio= "/audio_files/"
        os.makedirs(pathAudio + folderAudio, exist_ok=True)     
        full_path = pathAudio + folderAudio
        audio_file_path = os.path.join(full_path, audio_data)

        audioInput = speechsdk.AudioConfig(filename=audio_file_path)

        # Reconocedor con auto-detect + traducción
        recognizer = speechsdk.translation.TranslationRecognizer(
            translation_config=translation_config,
            audio_config=audioInput,
            auto_detect_source_language_config=auto_detect_source_language_config
        )

        result = recognizer.recognize_once_async().get()

        if result.reason == speechsdk.ResultReason.TranslatedSpeech:
            detected_lang = result.properties[
                speechsdk.PropertyId.SpeechServiceConnection_AutoDetectSourceLanguageResult
            ]
            print(f"Idioma detectado: {detected_lang}")
            print(f"Texto original: {result.text}")
            print(f"Traducción: {result.translations[target_language]}")
            return {
                "detected_language": detected_lang,
                "original_text": result.text,
                "translation": result.translations[target_language]
            }
        elif result.reason == speechsdk.ResultReason.NoMatch:
            return {"error": "No se reconoció nada en el audio"}
        else:
            return {"error": str(result.reason)}
    