from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route("/", methods=["GET"])
def root():
    return jsonify({"message": "TTT Server - Text to Text API"})

@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({"status": "healthy", "service": "TTT"})

@app.route("/process", methods=["POST"])
def process_text():
    """
    Endpoint para procesar texto (traducción, resumen, análisis)
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
        
        text = data.get("text")
        source_language = data.get("source_language", "es")
        target_language = data.get("target_language", "en")
        task = data.get("task", "translate")
        
        if not text:
            return jsonify({"error": "Text is required"}), 400
        
        # Simulación de procesamiento de texto
        # En un caso real, aquí se integraría con servicios de IA
        
        if task == "translate":
            mock_result = f"Translated text: {text}"
        elif task == "summarize":
            mock_result = f"Summary: {text[:50]}..."
        elif task == "analyze":
            mock_result = f"Analysis: Text contains {len(text)} characters"
        else:
            mock_result = f"Processed: {text}"
        
        return jsonify({
            "result": mock_result,
            "source_language": source_language,
            "target_language": target_language,
            "task": task,
            "confidence": 0.92
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/tasks", methods=["GET"])
def get_available_tasks():
    """
    Obtener tareas disponibles
    """
    return jsonify({
        "tasks": [
            {"id": "translate", "name": "Traducción", "description": "Traducir texto entre idiomas"},
            {"id": "summarize", "name": "Resumen", "description": "Generar resumen del texto"},
            {"id": "analyze", "name": "Análisis", "description": "Analizar contenido del texto"}
        ]
    })

@app.route("/languages", methods=["GET"])
def get_supported_languages():
    """
    Obtener idiomas soportados
    """
    return jsonify({
        "languages": ["es", "en", "fr", "de", "it", "pt"],
        "default_source": "es",
        "default_target": "en"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8003, debug=True)
