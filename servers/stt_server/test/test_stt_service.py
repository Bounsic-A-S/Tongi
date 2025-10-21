import os
import pytest
from unittest.mock import AsyncMock, patch
from models.stt_models import TranscriptionResponse, LanguagesResponse
from services.stt_service import STTService


@pytest.mark.asyncio
async def test_get_supported_languages_returns_expected_model():
    """Debe devolver un LanguagesResponse con idiomas soportados"""
    service = STTService()
    result = await service.get_supported_languages()

    assert isinstance(result, LanguagesResponse)
    assert result.default == "es"
    assert len(result.languages) > 0
    assert any(lang.code == "es" for lang in result.languages)


@pytest.mark.asyncio
async def test_transcribe_raises_if_file_missing():
    """Debe lanzar FileNotFoundError si el archivo no existe"""
    service = STTService()
    with patch("os.path.exists", return_value=False):
        with pytest.raises(FileNotFoundError):
            await service.transcribe("no_existe.wav", "es")


@pytest.mark.asyncio
async def test_translate_audio_raises_if_file_missing():
    """Debe lanzar FileNotFoundError si el archivo no existe"""
    service = STTService()
    with patch("os.path.exists", return_value=False):
        with pytest.raises(FileNotFoundError):
            await service.translate_audio("no_existe.wav", "es", "en")


@pytest.mark.asyncio
async def test_transcribe_returns_mock_response(monkeypatch):
    """Debe devolver una respuesta de transcripción simulada"""

    service = STTService()

    # Simulamos que el archivo existe
    monkeypatch.setattr("os.path.exists", lambda _: True)

    # Mock simple del resultado de Azure
    mock_result = type("MockResult", (), {"reason": "RecognizedSpeech", "text": "Hola mundo"})

    # Mock de la función interna que llama Azure
    async def fake_transcribe(*args, **kwargs):
        return TranscriptionResponse(text=mock_result.text, confidence=0.95, language="es")

    monkeypatch.setattr(service, "transcribe", fake_transcribe)

    response = await service.transcribe("mock.wav", "es")

    assert isinstance(response, TranscriptionResponse)
    assert response.text == "Hola mundo"
    assert response.language == "es"


@pytest.mark.asyncio
async def test_translate_audio_returns_mock_response(monkeypatch):
    """Debe devolver una respuesta de traducción simulada"""

    service = STTService()

    monkeypatch.setattr("os.path.exists", lambda _: True)

    async def fake_translate(*args, **kwargs):
        return TranscriptionResponse(text="Hello world", confidence=0.95, language="en")

    monkeypatch.setattr(service, "translate_audio", fake_translate)

    response = await service.translate_audio("mock.wav", "es", "en")

    assert isinstance(response, TranscriptionResponse)
    assert response.text == "Hello world"
    assert response.language == "en"
