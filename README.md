# Allot — Expense Tracker

Flutter (multi-platform) + Python Flask backend.

## Stack
- **Frontend**: Flutter (Dart ≥3.3.0) — Windows / Android / iOS
- **Backend**: Python Flask + SQLAlchemy (SQLite dev / PostgreSQL prod)
- **Auth**: JWT (Flask-JWT-Extended)
- **Charts**: fl_chart
- **State**: Provider pattern
- **Theme**: Material Design 3 — dark (black+green) / light (white+green)

## Default Users (auto-seeded)
| Username | Password | Role  |
|----------|----------|-------|
| admin    | admin123 | admin |
| invitado | (none)   | guest |

## Quick Start

### 1. Backend
```
cd backend
setup.bat          # creates venv, installs deps
run_backend.bat    # starts Flask on http://127.0.0.1:5000
```

### 2. Flutter (Windows)
```
cd flutter_app
flutter pub get
build_windows.bat  # outputs .exe
```

### 3. Flutter (Android)
```
cd flutter_app
build_android.bat  # outputs .apk
```

### 4. Flutter (iOS) — requires macOS + Xcode
```
cd flutter_app
flutter pub get
flutter build ipa --release
# .ipa is in build/ios/ipa/
```

## Environment Variables (`backend/.env`)
```
SECRET_KEY=change_me_in_production
JWT_SECRET_KEY=change_me_too
DATABASE_URL=sqlite:///allot.db
```

## API Base URL
Default: `http://127.0.0.1:5000/api`
Change in `flutter_app/lib/services/api_service.dart` → `baseUrl`.
