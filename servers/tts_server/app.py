from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route("/", methods=["GET"])
def root():
    return jsonify({"message": "TTS Server - Text to Speech API"})

@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({"status": "healthy", "service": "TTS"})

@app.route("/synthesize", methods=["POST"])
def synthesize_speech():
    """
    Endpoint para sintetizar voz desde texto
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
        
        text = data.get("text")
        language = data.get("language", "es")
        voice = data.get("voice", "default")
        
        if not text:
            return jsonify({"error": "Text is required"}), 400

        # Simulación de síntesis: audio base64 ficticio
        mock_audio_b64 = "UklGRiQAAABXQVZFZm10IBAAAAABAAEAESsAACJWAAACABAAZGF0YQAAAA=="

        return jsonify({
            "audio_data": mock_audio_b64,
            "language": language,
            "voice": voice,
            "sample_rate": 22050,
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/voices", methods=["GET"])
def get_available_voices():
    """
    Obtener voces disponibles por idioma
    """
    return jsonify({
        "languages": {
            "es": ["default", "female_1", "male_1"],
            "en": ["default", "female_1", "male_1"],
        },
        "default": {"es": "default", "en": "default"},
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8002, debug=True)


