from flask import Flask, request, jsonify
from flask_cors import CORS
from controllers.stt_controller import STTController;

app = Flask(__name__)
CORS(app)

stt_controller = STTController()

@app.route("/", methods=["GET"])
def root():
    return jsonify({"message": "STT Server - Speech to Text API"})

@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({"status": "healthy", "service": "STT"})

@app.route("/transcribe", methods=["POST"])
async def transcribe_audio():
    """
    Endpoint para transcribir audio a texto
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
        

        transcription = await stt_controller.transcribe_audio(data)
        
        return jsonify({
                "detected_language": transcription.detected_language,
                "original_text": transcription.original_text,
                "translation": transcription.translation
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/languages", methods=["GET"])
def get_supported_languages():
    """
    Obtener idiomas soportados
    """
    return jsonify({
        "languages": ["es", "en", "fr", "de"],
        "default": "es"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8001, debug=True)
