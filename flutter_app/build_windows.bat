@echo off
echo === Building Allot for Windows (.exe) ===
cd /d "%~dp0"
flutter pub get
flutter build windows --release
echo.
echo Build done: build\windows\x64\runner\Release\allot.exe
