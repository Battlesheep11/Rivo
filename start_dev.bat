@echo off
setlocal

REM === CONFIGURATION ===
set EMULATOR_PATH=C:\Users\Danag\AppData\Local\Android\Sdk\emulator\emulator.exe
set AVD_NAME=Pixel_5_API35_x86
set ADB_PATH=C:\Users\Danag\AppData\Local\Android\Sdk\platform-tools\adb.exe

echo ---------------------------------------------------
echo Starting RIVO DEV Environment
echo ---------------------------------------------------

REM === Check if emulator already running ===
%ADB_PATH% devices | findstr /C:"emulator" > nul
IF %ERRORLEVEL%==0 (
    echo Emulator already running.
) ELSE (
    echo Starting emulator: %AVD_NAME% ...
    start "" "%EMULATOR_PATH%" -avd %AVD_NAME%

    REM Give emulator time to spin up before checking adb
    echo Waiting 60 seconds for emulator boot initialization...
    timeout /t 60

    REM Check if emulator is visible in adb
    echo Checking for adb device...

    :adb_wait_loop
    %ADB_PATH% devices | findstr /C:"emulator" > nul
    IF %ERRORLEVEL% NEQ 0 (
        echo Emulator not detected by adb yet... waiting 5 sec
        timeout /t 5
        goto adb_wait_loop
    )
    echo Emulator connected to adb successfully!
)

REM === SAFETY: Confirm before running Flutter ===
choice /M "Do you want to continue to Flutter build & run?"
IF ERRORLEVEL 2 GOTO END_SCRIPT

REM === Full flutter build ===
echo ---------------------------------------------------
echo Cleaning Flutter build
flutter clean

echo ---------------------------------------------------
echo Getting Flutter dependencies
flutter pub get

echo ---------------------------------------------------
echo Running build_runner code generation
flutter pub run build_runner build --delete-conflicting-outputs

echo ---------------------------------------------------
echo Checking Flutter devices
flutter devices

echo ---------------------------------------------------
echo Launching Flutter app
flutter run

:END_SCRIPT
echo ---------------------------------------------------
echo Script terminated.
endlocal
pause
