@echo off
echo ===========================
echo Launching emulator...

REM מפעיל את האמולטור שלך (Pixel_6)
start "" "C:\Users\Danag\AppData\Local\Android\Sdk\emulator\emulator.exe" -avd Pixel_6

echo ===========================
echo Waiting for emulator to boot...

REM מחכה שהאמולטור יהיה online
adb wait-for-device

echo ===========================
echo Cleaning old build...
flutter clean

echo ===========================
echo Getting dependencies...
flutter pub get

echo ===========================
echo Building APK (debug, no-shrink)...
flutter build apk --debug --no-shrink

echo ===========================
echo Installing APK on emulator...
adb install -r build\app\outputs\flutter-apk\app-debug.apk

echo ===========================
echo Running Flutter app...
flutter run

pause
