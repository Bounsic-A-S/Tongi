@echo off
setlocal ENABLEDELAYEDEXPANSION

REM Ejecuta solo el servidor STT (puerto 8001)
pushd "%~dp0"

echo === STT Server ===

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

REM Instalar dependencias
echo Instalando dependencias STT...
python -m pip install --upgrade pip
pip install -r stt_server\requirements.txt

REM ---------------------------------------------
REM Ejecutar tests con python -m pytest y PYTHONPATH correcto
REM ---------------------------------------------
set PYTHONPATH=%CD%\stt_server
python -m pytest stt_server\test\test_stt_service.py -v -s

REM Iniciar servidor
cd stt_server
python app.py

popd
endlocal
