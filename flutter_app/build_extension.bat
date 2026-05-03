@echo off
echo ============================================
echo  Allot — Build Chrome Extension
echo ============================================

cd /d "%~dp0"

echo.
echo [1/2] Compilando Flutter web (renderer html + CSP)...
flutter build web --web-renderer html --csp --release

if errorlevel 1 (
    echo ERROR: Flutter build fallo.
    pause
    exit /b 1
)

echo.
echo [2/2] Extensión lista en: build\web\
echo.
echo Para instalar en Chrome:
echo   1. Abre chrome://extensions
echo   2. Activa "Modo de desarrollador" (arriba a la derecha)
echo   3. Clic en "Cargar descomprimida"
echo   4. Selecciona la carpeta: %~dp0build\web\
echo.
pause
