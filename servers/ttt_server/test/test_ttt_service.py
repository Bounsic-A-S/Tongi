import pytest
from unittest.mock import patch, MagicMock
from services.ttt_service import TTTService
from models.ttt_models import TextResponse, LanguageEnum


@pytest.mark.asyncio
async def test_process_text_translate():
    """Debe procesar texto y devolver traducción simulada"""
    service = TTTService()
    text = "Hola mundo"

    response: TextResponse = await service.process_text(text, "es", "en", "translate")

    assert isinstance(response, TextResponse)
    assert "Translated" in response.result
    assert response.source_language == "es"
    assert response.target_language == "en"
    assert response.task == "translate"
    assert 0 <= response.confidence <= 1


@pytest.mark.asyncio
async def test_get_available_tasks():
    """Debe devolver lista de tareas disponibles"""
    service = TTTService()
    result = await service.get_available_tasks()

    assert isinstance(result, dict)
    assert "tasks" in result
    assert isinstance(result["tasks"], list)
    assert len(result["tasks"]) >= 3
    assert all(hasattr(task, "id") for task in result["tasks"])


@pytest.mark.asyncio
async def test_get_supported_languages():
    """Debe listar idiomas soportados"""
    service = TTTService()
    result = await service.get_supported_languages()

    assert hasattr(result, "languages")
    assert len(result.languages) > 0
    assert result.default_source == "es"
    assert result.default_target == "en"


@patch("services.ttt_service.requests.post")
@pytest.mark.asyncio
async def test_translateAzure_success(mock_post):
    """Debe traducir texto correctamente con mock de Azure"""
    # Simulamos respuesta exitosa de Azure
    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.json.return_value = [{
        "translations": [{"text": "Hello world"}],
        "detectedLanguage": {"language": "es", "score": 0.99}
    }]
    mock_post.return_value = mock_response

    service = TTTService()
    response = await service.translateAzure("Hola mundo", "es", LanguageEnum.en)

    assert isinstance(response, TextResponse)
    assert "Hello world" in response.result
    assert response.confidence >= 0.99
    assert response.source_language == "es"
    assert response.target_language == LanguageEnum.en.value


@patch("services.ttt_service.requests.post", side_effect=Exception("Azure error"))
@pytest.mark.asyncio
async def test_translateAzure_error(mock_post):
    """Debe manejar errores de Azure correctamente"""
    service = TTTService()
    response = await service.translateAzure("Hola mundo", "es", LanguageEnum.en)

    assert isinstance(response, TextResponse)
    assert "Error en traducción" in response.result
    assert response.confidence == 0.0
