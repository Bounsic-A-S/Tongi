@echo off
setlocal ENABLEDELAYEDEXPANSION

REM Ejecuta solo el servidor TTT (puerto 8003)
pushd "%~dp0"

echo === TTT Server ===

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
echo Instalando dependencias TTT...
python -m pip install --upgrade pip
pip install -r ttt_server\requirements.txt

REM Iniciar servidor
cd ttt_server
python app.py

popd
endlocal
