@echo off
echo ====================================
echo  Chess Tournament - Auto Setup
echo ====================================
echo.

REM Check Flutter is installed
flutter --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter is not installed or not in PATH.
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo [1/4] Creating Flutter project...
flutter create chess_tournament --org com.example
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to create Flutter project.
    pause
    exit /b 1
)

echo [2/4] Copying source files...
xcopy /E /Y /I lib chess_tournament\lib\
copy /Y pubspec.yaml chess_tournament\pubspec.yaml
copy /Y README.md chess_tournament\README.md

echo [3/4] Getting packages...
cd chess_tournament
flutter pub get
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to get packages.
    pause
    exit /b 1
)

echo [4/4] Done!
echo.
echo ====================================
echo  SUCCESS! To run the app:
echo  1. cd chess_tournament
echo  2. flutter run
echo ====================================
echo.
echo Opening chess_tournament in VS Code...
code .
pause
