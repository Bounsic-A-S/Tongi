from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route("/", methods=["GET"])
def root():
    return jsonify({"message": "STT Server - Speech to Text API"})

@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({"status": "healthy", "service": "STT"})

@app.route("/transcribe", methods=["POST"])
def transcribe_audio():
    """
    Endpoint para transcribir audio a texto
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
        
        audio_data = data.get("audio_data")
        language = data.get("language", "es")
        
        if not audio_data:
            return jsonify({"error": "Audio data is required"}), 400
        
        # Simulación de transcripción
        # En un caso real, aquí se procesaría el audio
        mock_transcription = "Este es un texto de ejemplo transcrito del audio"
        
        return jsonify({
            "text": mock_transcription,
            "confidence": 0.95,
            "language": language
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
