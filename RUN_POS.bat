@echo off
where flutter >nul 2>nul || (echo Flutter SDK not found.& exit /b 1)
flutter run -d windows
