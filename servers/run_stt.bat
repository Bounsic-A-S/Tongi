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

REM Iniciar servidor
cd stt_server
python -m uvicorn app:app --host 0.0.0.0 --port 8001

popd
endlocal
