@echo off
setlocal ENABLEDELAYEDEXPANSION

REM Ejecuta STT, TTS y TTT cada uno en su propia ventana de CMD
pushd "%~dp0"

echo === Iniciando todos los servidores (STT/TTS/TTT) ===

REM Verificar Python
python --version >nul 2>&1
if errorlevel 1 (
  echo ERROR: Python no esta instalado o no esta en PATH
  pause
  exit /b 1
)

REM Crear entorno virtual si no existe
if not exist "venv\Scripts\python.exe" (
  echo Creando entorno virtual...
  python -m venv venv
)

REM Activar venv
call "venv\Scripts\activate.bat"
if errorlevel 1 (
  echo ERROR: No se pudo activar el entorno virtual
  pause
  exit /b 1
)

echo Instalando dependencias de todos los servidores...
python -m pip install --upgrade pip
pip install -r stt_server\requirements.txt -r tts_server\requirements.txt -r ttt_server\requirements.txt

REM Lanzar ventanas separadas
start "STT 8001" cmd /k "cd /d %cd%\stt_server && call ..\venv\Scripts\activate.bat && python app.py"
start "TTS 8002" cmd /k "cd /d %cd%\tts_server && call ..\venv\Scripts\activate.bat && python app.py"
start "TTT 8003" cmd /k "cd /d %cd%\ttt_server && call ..\venv\Scripts\activate.bat && python app.py"

echo.
echo STT: http://localhost:8001/
echo TTS: http://localhost:8002/
echo TTT: http://localhost:8003/

popd
endlocal
