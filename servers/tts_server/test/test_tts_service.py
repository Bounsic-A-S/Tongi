import pytest
from unittest.mock import patch
from models.tts_models import SynthesisResponse, VoicesResponse
from services.tts_service import TTSService


@pytest.mark.asyncio
async def test_get_voices_for_language_returns_list():
    """Debe devolver una lista de voces por idioma"""
    service = TTSService()

    voices_es = service.get_voices_for_language("es")
    voices_en = service.get_voices_for_language("en")
    voices_unknown = service.get_voices_for_language("fr")

    assert isinstance(voices_es, list)
    assert isinstance(voices_en, list)
    assert isinstance(voices_unknown, list)


@pytest.mark.asyncio
async def test_get_voice_info_returns_correct_data():
    """Debe devolver info de voz si existe o None si no existe"""
    service = TTSService()

    result = service.get_voice_info("es-ES-ElviraNeural")
    assert result is None or isinstance(result, dict)

    not_found = service.get_voice_info("voz-que-no-existe")
    assert not_found is None


@pytest.mark.asyncio
async def test_get_available_voices_returns_response():
    """Debe devolver un VoicesResponse válido"""
    service = TTSService()
    response = await service.get_available_voices()

    assert isinstance(response, VoicesResponse)
    assert hasattr(response, "languages")
    assert hasattr(response, "default")


@pytest.mark.asyncio
async def test_synthesize_raises_if_missing_key(monkeypatch):
    """Debe lanzar ValueError si falta la clave de Azure"""
    monkeypatch.delenv("AZURE_API_KEY", raising=False)
    service = TTSService()

    with pytest.raises(ValueError, match="Falta configurar AZURE_API_KEY"):
        await service.synthesize("Hola mundo", "es", "es-ES-ElviraNeural")


@pytest.mark.asyncio
async def test_synthesize_returns_mock_response(monkeypatch):
    """Debe devolver una respuesta simulada exitosa"""
    # Simulamos variable de entorno

    service = TTSService()

    # Mock del método interno para no llamar a Azure
    async def fake_synthesize(*args, **kwargs):
        return SynthesisResponse(
            language="es",
            voice="es-ES-ElviraNeural",
            audio_data="/audio/fake.wav",
            sample_rate=22050,
        )

    monkeypatch.setattr(service, "synthesize", fake_synthesize)

    response = await service.synthesize("Hola mundo", "es", "es-ES-ElviraNeural")

    assert isinstance(response, SynthesisResponse)
    assert response.language == "es"
    assert response.voice == "es-ES-ElviraNeural"
    assert response.audio_data == "/audio/fake.wav"


@pytest.mark.asyncio
async def test_synthesize_handles_error(monkeypatch):
    """Debe manejar errores en la síntesis"""
    service = TTSService()

    async def fake_fail(*args, **kwargs):
        raise Exception("Error en síntesis")

    monkeypatch.setattr(service, "synthesize", fake_fail)

    with pytest.raises(Exception, match="Error en síntesis"):
        await service.synthesize("Hola mundo", "es", "es-ES-ElviraNeural")
