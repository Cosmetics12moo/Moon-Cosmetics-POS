@echo off
setlocal
where flutter >nul 2>nul || (echo Flutter SDK not found. Install Flutter and add it to PATH.& exit /b 1)
flutter pub get
flutter analyze
flutter test
flutter build windows --release
if errorlevel 1 exit /b %errorlevel%
echo Build complete. EXE is under build\windows\x64\runner\Release\
endlocal
