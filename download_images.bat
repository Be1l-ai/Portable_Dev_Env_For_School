@echo off
REM download_images.bat - Download container images from GitHub Releases (Windows)
REM Usage: download_images.bat [REPO] [VERSION]

setlocal enabledelayedexpansion

REM Configuration (edit these or pass as arguments)
set REPO=%1
if "%REPO%"=="" set REPO=Be1l-ai/Portable_Dev_Env_For_School

set VERSION=%2
if "%VERSION%"=="" set VERSION=v1.0

echo ========================================
echo   Container Images Download Script
echo ========================================
echo Repository: %REPO%
echo Version: %VERSION%
echo.

REM Check if images directory exists
if not exist "images\" (
    echo Creating images directory...
    mkdir images
)

REM Download Python container image
set PYTHON_URL=https://github.com/%REPO%/releases/download/%VERSION%/python-gui.tar
set PYTHON_FILE=images\python-gui.tar

if exist "%PYTHON_FILE%" (
    echo Python container image already exists. Skipping download.
) else (
    echo Downloading Python container image (~1.8 GB)...
    curl -L -o "%PYTHON_FILE%" "%PYTHON_URL%"
    if errorlevel 1 (
        echo ERROR: Failed to download Python image.
        pause
        exit /b 1
    )
    echo Python image downloaded successfully!
)

echo.

REM Download Java container image
set JAVA_URL=https://github.com/%REPO%/releases/download/%VERSION%/java-gui.tar
set JAVA_FILE=images\java-gui.tar

if exist "%JAVA_FILE%" (
    echo Java container image already exists. Skipping download.
) else (
    echo Downloading Java container image (~1.6 GB)...
    curl -L -o "%JAVA_FILE%" "%JAVA_URL%"
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
