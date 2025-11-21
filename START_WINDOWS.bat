@echo off
REM Portable Dev Environment for Windows
REM Starts VcXsrv X11 server and containers for Python/Java GUI development
REM Supports both Docker and Podman

echo Starting VcXsrv X11 server...
start "" "%~dp0vcxsrv\vcxsrv.exe" -multiwindow -clipboard -wgl -ac

echo.
echo Detecting container runtime...

REM Check for Docker first (most common on school PCs)
docker --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set CONTAINER_CMD=docker
    echo Found Docker! Using docker command.
    goto :runtime_ready
)

REM Check for Podman
podman --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set CONTAINER_CMD=podman
    echo Found Podman! Using podman command.
    
    REM Initialize Podman machine if needed
    echo Initializing Podman machine (first time only)...
    podman machine init --now 2>nul
    podman machine start 2>nul
    goto :runtime_ready
)

REM No container runtime found
echo.
echo ERROR: No container runtime found!
echo Please install either:
echo   - Docker Desktop: https://www.docker.com/products/docker-desktop
echo   - Podman Desktop: https://podman-desktop.io/
echo.
pause
exit /b 1

:runtime_ready
echo.
echo ========================================
echo   Portable Dev Environment Ready
echo   Using: %CONTAINER_CMD%
echo ========================================
echo.
echo Choose your environment:
echo   [p] Python + PyQt6
echo   [j] Java + Swing
echo.
set /p choice="Enter your choice (p/j): "

if /i "%choice%"=="p" (
    echo.
    echo Starting Python container with GUI support...
    %CONTAINER_CMD% run -it --rm ^
        -v "%~dp0projects\python:/workspace" ^
        -w /workspace ^
        --env DISPLAY=host.docker.internal:0 ^
        --name python-dev ^
        python-gui bash
) else if /i "%choice%"=="j" (
    echo.
    echo Starting Java container with GUI support...
    %CONTAINER_CMD% run -it --rm ^
        -v "%~dp0projects\java:/workspace" ^
        -w /workspace ^
        --env DISPLAY=host.docker.internal:0 ^
        --name java-dev ^
        java-gui bash
) else (
    echo Invalid choice. Please run the script again and choose 'p' or 'j'.
    pause
    exit /b 1
)

echo.
echo Container stopped. Press any key to exit...
pause >nul
