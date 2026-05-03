@echo off
echo === Allot Backend Setup ===

cd /d "%~dp0"

REM Create virtual environment
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate and install deps
call venv\Scripts\activate.bat
pip install -r requirements.txt

REM Copy env if missing
if not exist ".env" (
    copy .env.example .env
    echo .env created from template. Edit it before running in production.
)

echo.
echo Setup complete! Run run_backend.bat to start the server.
