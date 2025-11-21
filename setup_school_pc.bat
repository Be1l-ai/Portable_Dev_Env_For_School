@echo off
REM setup_school_pc.bat - Automated setup for school PC with WSL2
REM Run this ONCE on each school PC to set up the development environment
REM Note: May require admin rights for initial WSL2/Docker installation

echo ========================================
echo   School PC Setup - WSL2 + Docker
echo ========================================
echo.
echo This script will:
echo   1. Check/Enable WSL2
echo   2. Install Ubuntu on WSL2
echo   3. Install Docker Desktop
echo   4. Load container images from USB
echo.
echo NOTE: First-time setup may require admin rights.
echo       After setup, no admin needed for daily use!
echo.
pause

REM ============================================
REM Step 1: Check if WSL2 is installed
REM ============================================
echo.
echo [Step 1/5] Checking WSL2...
wsl --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   ✓ WSL2 is already installed
    goto :check_ubuntu
) else (
    echo   ✗ WSL2 not found
    echo.
    echo Installing WSL2 (requires admin)...
    echo Please approve the UAC prompt if it appears.
    
    REM Try to install WSL2
    powershell -Command "Start-Process wsl -ArgumentList '--install' -Verb RunAs -Wait"
    
    if %ERRORLEVEL% EQU 0 (
        echo   ✓ WSL2 installed! You may need to restart your PC.
        echo.
        echo Please restart your PC and run this script again.
        pause
        exit /b 0
    ) else (
        echo   ✗ Failed to install WSL2
        echo.
        echo Manual steps:
        echo   1. Open PowerShell as Administrator
        echo   2. Run: wsl --install
        echo   3. Restart PC
        echo   4. Run this script again
        pause
        exit /b 1
    )
)

:check_ubuntu
REM ============================================
REM Step 2: Check if Ubuntu is installed
REM ============================================
echo.
echo [Step 2/5] Checking Ubuntu on WSL...
wsl -l -v | find "Ubuntu" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   ✓ Ubuntu is already installed
    goto :check_docker
) else (
    echo   ✗ Ubuntu not found
    echo.
    echo Installing Ubuntu...
    wsl --install -d Ubuntu
    
    if %ERRORLEVEL% EQU 0 (
        echo   ✓ Ubuntu installed!
        echo.
        echo Please set up your Ubuntu username/password when prompted.
        wsl -d Ubuntu
    ) else (
        echo   ✗ Failed to install Ubuntu
        echo.
        echo Manual steps:
        echo   1. Open Microsoft Store
        echo   2. Search for "Ubuntu"
        echo   3. Install Ubuntu 24.04 LTS
        pause
        exit /b 1
    )
)

:check_docker
REM ============================================
REM Step 3: Check if Docker is installed
REM ============================================
echo.
echo [Step 3/5] Checking Docker Desktop...
docker --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   ✓ Docker is already installed
    docker --version
    goto :load_images
) else (
    echo   ✗ Docker not found
    echo.
    echo Docker Desktop needs to be installed manually.
    echo.
    echo Options:
    echo   [1] Download Docker Desktop now (opens browser)
    echo   [2] I'll install it later
    echo   [3] Try Podman instead
    echo.
    set /p docker_choice="Choose (1/2/3): "
    
    if "%docker_choice%"=="1" (
        echo Opening Docker Desktop download page...
        start https://www.docker.com/products/docker-desktop
        echo.
        echo After installing Docker Desktop:
        echo   1. Restart this script
        echo   2. Or manually load images with: docker load -i E:\images\python-gui.tar
        pause
        exit /b 0
    ) else if "%docker_choice%"=="3" (
        goto :try_podman
    ) else (
        echo.
        echo Please install Docker Desktop manually from:
        echo   https://www.docker.com/products/docker-desktop
        echo.
        echo Then run this script again to load container images.
        pause
        exit /b 0
    )
)

:try_podman
echo.
echo Checking for Podman...
podman --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   ✓ Podman is installed
    set CONTAINER_CMD=podman
    goto :load_images
) else (
    echo   ✗ Podman not found
    echo.
    echo Please install either Docker Desktop or Podman Desktop:
    echo   Docker:  https://www.docker.com/products/docker-desktop
    echo   Podman:  https://podman-desktop.io/
    pause
    exit /b 1
)

:load_images
REM ============================================
REM Step 4: Detect USB drive with images
REM ============================================
echo.
echo [Step 4/5] Looking for USB drive with container images...

REM Check common drive letters for USB
set USB_DRIVE=
for %%d in (D E F G H I J K) do (
    if exist %%d:\images\python-gui.tar (
        set USB_DRIVE=%%d:
        goto :found_usb
    )
)

echo   ✗ USB drive not found
echo.
echo Please:
echo   1. Insert your USB drive
echo   2. Make sure it contains images\python-gui.tar and images\java-gui.tar
echo   3. Run this script again
pause
exit /b 1

:found_usb
echo   ✓ Found USB at %USB_DRIVE%
echo.

REM Check if VcXsrv is on USB
if exist %USB_DRIVE%\vcxsrv\vcxsrv.exe (
    echo   ✓ VcXsrv found on USB
) else (
    echo   ⚠ VcXsrv not found on USB
    echo.
    echo VcXsrv is needed for GUI apps on Windows.
    echo Please add it to %USB_DRIVE%\vcxsrv\
    echo.
    echo See USB_SETUP.md Step 4 for instructions.
    echo.
    set /p continue_anyway="Continue without VcXsrv? (y/n): "
    if /i not "%continue_anyway%"=="y" (
        echo.
        echo Setup cancelled. Please add VcXsrv to USB and run again.
        pause
        exit /b 1
    )
)

echo.

REM Detect which container runtime to use
if defined CONTAINER_CMD (
    REM Already set from podman check
    set RUNTIME=%CONTAINER_CMD%
) else (
    docker --version >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set RUNTIME=docker
    ) else (
        podman --version >nul 2>&1
        if %ERRORLEVEL% EQU 0 (
            set RUNTIME=podman
        ) else (
            echo ERROR: No container runtime found!
            pause
            exit /b 1
        )
    )
)

echo Using: %RUNTIME%
echo.

REM ============================================
REM Step 5: Load container images
REM ============================================
echo [Step 5/5] Loading container images...
echo This may take 2-3 minutes...
echo.

REM Check if images already loaded
%RUNTIME% images | find "python-gui" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   ✓ python-gui already loaded
) else (
    echo Loading python-gui.tar (~1.8 GB)...
    %RUNTIME% load -i %USB_DRIVE%\images\python-gui.tar
    if %ERRORLEVEL% EQU 0 (
        echo   ✓ python-gui loaded successfully
    ) else (
        echo   ✗ Failed to load python-gui
    )
)

echo.

%RUNTIME% images | find "java-gui" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   ✓ java-gui already loaded
) else (
    echo Loading java-gui.tar (~1.6 GB)...
    %RUNTIME% load -i %USB_DRIVE%\images\java-gui.tar
    if %ERRORLEVEL% EQU 0 (
        echo   ✓ java-gui loaded successfully
    ) else (
        echo   ✗ Failed to load java-gui
    )
)

echo.
echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo Container images are now loaded on this PC.
echo.
echo Daily usage:
echo   1. Plug in your USB
echo   2. Run: %USB_DRIVE%\START_WINDOWS.bat
echo   3. Choose Python or Java
echo   4. Start coding!
echo.
echo Images loaded:
%RUNTIME% images
echo.
pause
