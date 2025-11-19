@echo off
REM Portable Dev Environment for Windows
REM Starts VcXsrv X11 server and Podman containers for Python/Java GUI development

echo Starting VcXsrv X11 server...
start "" "%~dp0vcxsrv\vcxsrv.exe" -multiwindow -clipboard -wgl -ac

echo.
echo Initializing Podman machine (first time only)...
"%~dp0podman\podman.exe" machine init --now 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Podman machine initialized.
) else (
    echo Podman machine already exists or starting existing machine...
)

echo Starting Podman machine...
"%~dp0podman\podman.exe" machine start 2>nul

echo.
echo ========================================
echo   Portable Dev Environment Ready
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
    "%~dp0podman\podman.exe" run -it --rm ^
        -v "%~dp0projects\python:/workspace" ^
        -w /workspace ^
        --env DISPLAY=host.docker.internal:0 ^
        --name python-dev ^
        python-gui bash
) else if /i "%choice%"=="j" (
    echo.
    echo Starting Java container with GUI support...
    "%~dp0podman\podman.exe" run -it --rm ^
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
