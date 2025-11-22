@echo off
REM download_images.bat - Download container images from GitHub Releases (Windows)
REM Usage: download_images.bat [REPO] [VERSION]

REM Navigate to repo root (2 levels up from scripts/build/)
cd /d "%~dp0..\.."

REM Use safe variable setting (prevents parsing issues with spaces/special chars)
set "REPO=%~1"
if "%REPO%"=="" set "REPO=Be1l-ai/Portable_Dev_Env_For_School"

set "VERSION=%~2"
if "%VERSION%"=="" set "VERSION=v1.0"

echo ========================================
echo   Container Images Download Script
echo ========================================
echo Repository: %REPO%
echo Version: %VERSION%
echo.

REM Create images directory if missing (avoid quoting a trailing backslash)
if not exist images (
    echo Creating images directory...
    mkdir images
)

REM Detect available downloader: curl, wget, or PowerShell fallback
where curl >nul 2>&1
if %errorlevel%==0 (
    set "DOWNLOADER=curl"
) else (
    where wget >nul 2>&1
    if %errorlevel%==0 (
        set "DOWNLOADER=wget"
    ) else (
        set "DOWNLOADER=powershell"
    )
)
echo Using downloader: %DOWNLOADER%

REM Build URLs and file paths using quoted set to avoid trailing-space issues
set "PYTHON_URL=https://github.com/%REPO%/releases/download/%VERSION%/python-gui.tar"
set "PYTHON_FILE=images\python-gui.tar"

if exist "%PYTHON_FILE%" (
    echo Python container image already exists. Skipping download.
) else (
    echo Downloading Python container image (~1.1 GB)...
    echo URL: %PYTHON_URL%
    if "%DOWNLOADER%"=="curl" (
        curl -L --progress-bar -o "%PYTHON_FILE%" "%PYTHON_URL%"
    ) else if "%DOWNLOADER%"=="wget" (
        wget -c -O "%PYTHON_FILE%" "%PYTHON_URL%"
    ) else (
        powershell -NoProfile -Command "try { Write-Host 'Using PowerShell Invoke-WebRequest...'; Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile '%PYTHON_FILE%' -UseBasicParsing } catch { exit 1 }"
    )
    if errorlevel 1 (
        echo ERROR: Failed to download Python image.
        pause
        exit /b 1
    )
    echo Python image downloaded successfully!
)

echo.

set "JAVA_URL=https://github.com/%REPO%/releases/download/%VERSION%/java-gui.tar"
set "JAVA_FILE=images\java-gui.tar"

if exist "%JAVA_FILE%" (
    echo Java container image already exists. Skipping download.
) else (
    echo Downloading Java container image (~1.1 GB)...
    echo URL: %JAVA_URL%
    if "%DOWNLOADER%"=="curl" (
        curl -L --progress-bar -o "%JAVA_FILE%" "%JAVA_URL%"
    ) else if "%DOWNLOADER%"=="wget" (
        wget -c -O "%JAVA_FILE%" "%JAVA_URL%"
    ) else (
        powershell -NoProfile -Command "try { Write-Host 'Using PowerShell Invoke-WebRequest...'; Invoke-WebRequest -Uri '%JAVA_URL%' -OutFile '%JAVA_FILE%' -UseBasicParsing } catch { exit 1 }"
    )
    if errorlevel 1 (
        echo ERROR: Failed to download Java image.
        pause
        exit /b 1
    )
    echo Java image downloaded successfully!
)

echo.
echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo Container images downloaded successfully.
echo Run START_WINDOWS.bat to start the development environment.
echo.
pause
