@echo off
echo ================================================================
echo  Allot — Build para iPhone (.ipa)
echo ================================================================
echo.
echo IMPORTANTE: El archivo .ipa SOLO puede compilarse en macOS con Xcode.
echo Este script te guia para hacerlo desde una Mac o en CI/CD (GitHub Actions).
echo.
echo ── Opcion 1: Compilar en Mac ──────────────────────────────────
echo  1. Copia este proyecto a una Mac con Xcode instalado.
echo  2. Abre una terminal en la carpeta flutter_app/.
echo  3. Ejecuta:
echo.
echo     flutter pub get
echo     flutter build ipa --release --dart-define=API_URL=https://allot-backend.onrender.com/api
echo.
echo  4. El .ipa estara en: build/ios/ipa/allot.ipa
echo  5. Distribuyelo via TestFlight o AdHoc con Apple Configurator.
echo.
echo ── Opcion 2: GitHub Actions (build en la nube) ─────────────────
echo  El proyecto incluye el workflow .github/workflows/build_ios.yml
echo  Solo haz push a la rama main y descarga el .ipa desde Artifacts.
echo.
echo ── Opcion 3: Codemagic (gratuito para proyectos Flutter) ───────
echo  https://codemagic.io — conecta tu repo y genera el .ipa en la nube.
echo.
echo ================================================================
pause
