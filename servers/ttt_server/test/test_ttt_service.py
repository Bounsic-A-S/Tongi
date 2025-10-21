import pytest
from unittest.mock import patch, MagicMock
from services.ttt_service import TTTService
from models.ttt_models import TextResponse, LanguageEnum


@pytest.mark.asyncio
async def test_process_text_translate():
    service = TTTService()
    text = "Hola mundo"
    response: TextResponse = await service.process_text(text, "es", "en", "translate")
    
    assert "Translated" in response.result
    assert response.source_language == "es"
    assert response.target_language == "en"
    assert response.task == "translate"
    assert 0 <= response.confidence <= 1


@pytest.mark.asyncio
async def test_process_text_summarize():
    service = TTTService()
    text = "Este es un texto muy largo que debería ser resumido correctamente para la prueba unitaria"
    response: TextResponse = await service.process_text(text, "es", "es", "summarize")

    assert response.result.startswith("Resumen:")
    assert "..." in response.result


@pytest.mark.asyncio
async def test_process_text_analyze():
    service = TTTService()
    text = "Esto es una prueba corta"
    response: TextResponse = await service.process_text(text, "es", "es", "analyze")

    assert "caracteres" in response.result
    assert "palabras" in response.result


@pytest.mark.asyncio
async def test_get_available_tasks():
    service = TTTService()
    result = await service.get_available_tasks()
    
    assert "tasks" in result
    assert len(result["tasks"]) >= 3
    assert all(hasattr(task, "id") for task in result["tasks"])


@pytest.mark.asyncio
async def test_get_supported_languages():
    service = TTTService()
    result = await service.get_supported_languages()
    
    assert len(result.languages) > 0
    assert result.default_source == "es"
    assert result.default_target == "en"


@patch("services.ttt_service.requests.post")
@pytest.mark.asyncio
async def test_translateAzure_success(mock_post):
    """
    Simula una respuesta exitosa del servicio Azure Translate
    """
    mock_response = MagicMock()
    mock_response.json.return_value = [
        {
            "translations": [{"text": "Hello world"}],
            "detectedLanguage": {"language": "es", "score": 0.99}
        }
    ]
    mock_response.status_code = 200
    mock_post.return_value = mock_response

    service = TTTService()
    service.api_key = "fake"
    service.endpoint = "https://fake-endpoint"
    service.location = "eastus"

    response = await service.translateAzure("Hola mundo", "es", LanguageEnum.en)
    assert isinstance(response, TextResponse)
    assert "Hello world" in response.result
    assert response.confidence > 0.9


@patch("services.ttt_service.requests.post", side_effect=Exception("Azure error"))
@pytest.mark.asyncio
async def test_translateAzure_error(mock_post):
    """
    Simula un error en la API de Azure
    """
    service = TTTService()
    service.api_key = "fake"
    service.endpoint = "https://fake-endpoint"
    service.location = "eastus"

    response = await service.translateAzure("Hola mundo", "es", LanguageEnum.en)
    assert "Error en traducción" in response.result
    assert response.confidence == 0.0
