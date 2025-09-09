from flask import Flask, request, jsonify, abort
from flask_cors import CORS
from controllers.ttt_controller import TTTController
from models.ttt_models import TextRequest

app = Flask(__name__)
CORS(app)

# Instanciar el controlador
ttt_controller = TTTController()

@app.route("/", methods=["GET"])
def root():
    return jsonify({"message": "TTT Server - Text to Text API"})

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "TTT"}

@app.route("/process", methods=["POST"])
async def process_text():
    """
    Endpoint para procesar texto (traducción, resumen, análisis)
    """
    try:
        # Simulación de procesamiento de texto
        # En un caso real, aquí se integraría con servicios de IA

         # Obtener datos del request
        data = request.get_json()

        text = data.get("text")
        source_language = data.get("source_language")
        target_language = data.get("target_language")
        task = data.get("task")
        
        # Crear objeto TextRequest
        text_request = TextRequest(
            text=text,
            source_language=source_language,
            target_language=target_language,
            task=task
        )
        print(text_request)
        
        # Procesar con el controlador
        result =await ttt_controller.process_text(text_request)
        
        return jsonify({
            "result": result.result,
            "source_language": result.source_language,
            "target_language": result.target_language,
            "task": result.task,
            "confidence": result.confidence
        })
    except Exception as e:
        abort(status_code=500, detail=str(e))

@app.get("/tasks")
async def get_available_tasks():
    """
    Obtener tareas disponibles
    """
    try:
        tasks = ttt_controller.get_available_tasks()
        return jsonify(tasks)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.get("/languages")
async def get_supported_languages():
    """
    Obtener idiomas soportados
    """
    try:
        languages = ttt_controller.get_supported_languages()
        return jsonify(languages)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8003, debug=True)

