from flask import Flask, request, jsonify
from flask_cors import CORS
from controllers.tts_controller import TTSController
from models.tts_models import SynthesisRequest

app = Flask(__name__)
CORS(app)
controller = TTSController();
@app.route("/", methods=["GET"])
def root():
    return jsonify({"message": "TTS Server - Text to Speech API"})

@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({"status": "healthy", "service": "TTS"})

@app.route("/text-voice", methods=["POST"])
async def synthesize_speech():
    """
    Endpoint para sintetizar voz desde texto
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
        
        text = data.get("text")
        language = data.get("language", "en-US")
        voice = data.get("voice", "BrandonMultilingualNeural")
        
        if not text:
            return jsonify({"error": "Text is required"}), 400

        request_data = SynthesisRequest(
            text=text,
            language=language,
            voice=voice
        )

        response = await controller.synthesize(request_data)
        return jsonify(response)
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


