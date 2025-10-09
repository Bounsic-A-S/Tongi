@echo off
setlocal ENABLEDELAYEDEXPANSION

echo === Dockerizando todos los servidores (STT/TTS/TTT) ===

docker build -t tts-server:latest .\tts_server

docker build -t ttt-server:latest .\ttt_server

docker build -t stt-server:latest .\stt_server

docker run -d --name ttt-server -p 8001:8001 -e AZURE_API_KEY="" -e AZURE_ENDPOINT=""  -e AZURE_LOCATION="" ttt-server:latest
docker run -d --name stt-server -p 8003:8003 -e AZURE_API_KEY="" -e AZURE_ENDPOINT=""  -e AZURE_LOCATION="" stt-server:latest
docker run -d --name tts-server -p 8002:8002 -e AZURE_API_KEY="" -e AZURE_ENDPOINT=""  -e AZURE_LOCATION="" tts-server:latest

echo.
echo STT: http://localhost:8003/
echo TTS: http://localhost:8002/
echo TTT: http://localhost:8001/

endlocal
