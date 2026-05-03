@echo off
echo === Building Allot for Android (.apk) ===
cd /d "%~dp0"
flutter pub get
flutter build apk --release
echo.
echo Build done: build\app\outputs\flutter-apk\app-release.apk
