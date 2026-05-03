@echo off
cd /d "%~dp0"
call venv\Scripts\activate.bat
set FLASK_APP=app.py
set FLASK_ENV=development
python app.py
