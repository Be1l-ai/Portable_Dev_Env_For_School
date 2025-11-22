@echo off
REM auto-setup.bat - Master automation script for Windows
REM Automatically sets up everything in the correct order

setlocal EnableDelayedExpansion

echo ================================================
echo   Portable Dev Environment - Auto Setup
echo ================================================
echo.
echo This script will automatically:
echo   1. Check container runtime (Docker/Podman/WSL2)
echo   2. Detect USB drive
echo   3. Check/build/download container images
echo   4. Load images into container runtime
echo   5. Set up Windows tools (VcXsrv, Qt Designer, Eclipse)
echo   6. Launch the development environment
echo.
pause

REM Get script directory (repo root)
set "REPO_ROOT=%~dp0"
cd /d "%REPO_ROOT%"

REM ============================================
REM Step 1: Check container runtime (MUST BE FIRST)
REM ============================================
echo.
echo [Step 1/6] Checking container runtime...

docker --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   ✓ Docker found
    set RUNTIME=docker
    set RUNTIME_OK=1
    goto :detect_usb
)

podman --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   ✓ Podman found
    set RUNTIME=podman
    set RUNTIME_OK=1
    goto :detect_usb
)

echo   ✗ No container runtime found (Docker or Podman needed)
echo.
echo This PC needs setup to run containers.
echo Run school PC setup now? (Installs WSL2/Docker) (y/n)
set /p do_school_setup=""
if /i "!do_school_setup!"=="y" (
    call scripts\setup\setup_school_pc.bat
    if errorlevel 1 (
        echo.
        echo Setup incomplete. Please complete setup and run auto-setup.bat again.
        pause
        exit /b 1
    )
    REM Check again after setup
    docker --version >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set RUNTIME=docker
        set RUNTIME_OK=1
    ) else (
        echo.
        echo Docker still not available. Please restart your PC and run auto-setup.bat again.
        pause
        exit /b 1
    )
) else (
    echo.
    echo Cannot continue without container runtime.
    echo Please install Docker Desktop or run setup_school_pc.bat
    pause
    exit /b 1
)

REM ============================================
REM Step 2: Detect USB drive
REM ============================================
:detect_usb
echo.
echo [Step 2/6] Detecting USB drive...

set USB_DRIVE=
for %%d in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%d:\START_WINDOWS.bat" (
        set USB_DRIVE=%%d:
        goto :usb_found
    )
    if exist "%%d:\config" (
        if exist "%%d:\projects" (
            set USB_DRIVE=%%d:
            goto :usb_found
        )
    )
)

echo   ⚠ USB drive not detected
echo   Running from local directory: %REPO_ROOT%
set USB_MODE=0
goto :check_images

:usb_found
echo   ✓ USB drive detected at %USB_DRIVE%
set USB_MODE=1

REM ============================================
REM Step 3: Check for container images
REM ============================================
:check_images
echo.
echo [Step 3/6] Checking container images...

set IMAGES_EXIST=0
set IMAGE_LOCATION=

REM Check USB first if available
if !USB_MODE!==1 (
    if exist "%USB_DRIVE%\images\python-gui.tar" (
        if exist "%USB_DRIVE%\images\java-gui.tar" (
            set IMAGES_EXIST=1
            set "IMAGE_LOCATION=%USB_DRIVE%\images"
            echo   ✓ Container images found on USB
            goto :load_images
        )
    )
)

REM Check local images folder
if exist "images\python-gui.tar" (
    if exist "images\java-gui.tar" (
        set IMAGES_EXIST=1
        set IMAGE_LOCATION=images
        echo   ✓ Container images found locally
        goto :load_images
    )
)

echo   ✗ Container images not found
echo.
echo Choose how to get container images:
echo   [1] Download from GitHub Releases (~2.2 GB, 3-5 minutes)
echo   [2] Build locally with WSL2 (requires Linux, 10-15 minutes)
echo   [3] Skip (I'll add them manually later)
echo.
set /p image_choice="Choose (1/2/3): "

if "!image_choice!"=="1" (
    echo.
    echo Downloading images from GitHub...
    call scripts\build\download_images.bat
    if errorlevel 1 (
        echo ERROR: Download failed.
        pause
        exit /b 1
    )
    set IMAGE_LOCATION=images
    set IMAGES_EXIST=1
) else if "!image_choice!"=="2" (
    echo.
    echo Building images with WSL2...
    echo This will take 15-20 minutes.
    set /p confirm_build="Continue? (y/n): "
    if /i "!confirm_build!"=="y" (
        echo.
        echo Starting build in WSL2...
        wsl bash -c "cd '%CD%' && scripts/build/build_images.sh all"
        if errorlevel 1 (
            echo ERROR: Build failed.
            pause
            exit /b 1
        )
        set IMAGE_LOCATION=images
        set IMAGES_EXIST=1
    ) else (
        echo Skipping build.
    )
) else (
    echo.
    echo Skipping image setup. You'll need to add images manually.
    set IMAGES_EXIST=0
)

REM ============================================
REM Step 4: Load images into container runtime
REM ============================================
:load_images
echo.
echo [Step 4/6] Loading images into %RUNTIME%...

if !IMAGES_EXIST!==0 (
    echo   ⚠ No images to load (skipped)
    goto :check_tools
)

REM Check if images already loaded
%RUNTIME% images | find "python-gui" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   ✓ python-gui already loaded
    set PYTHON_LOADED=1
) else (
    echo Loading python-gui.tar...
    %RUNTIME% load -i "%IMAGE_LOCATION%\python-gui.tar"
    if %ERRORLEVEL% EQU 0 (
        echo   ✓ python-gui loaded
        set PYTHON_LOADED=1
    ) else (
        echo   ✗ Failed to load python-gui
        set PYTHON_LOADED=0
    )
)

%RUNTIME% images | find "java-gui" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo   ✓ java-gui already loaded
    set JAVA_LOADED=1
) else (
    echo Loading java-gui.tar...
    %RUNTIME% load -i "%IMAGE_LOCATION%\java-gui.tar"
    if %ERRORLEVEL% EQU 0 (
        echo   ✓ java-gui loaded
        set JAVA_LOADED=1
    ) else (
        echo   ✗ Failed to load java-gui
        set JAVA_LOADED=0
    )
)

REM ============================================
REM Step 5: Check Windows tools on USB
REM ============================================
:check_tools
echo.
echo [Step 5/6] Checking Windows tools...

if !USB_MODE!==0 (
    echo   Skipped (not running from USB)
    goto :launch
)

REM Check for VcXsrv
if exist "%USB_DRIVE%\vcxsrv\vcxsrv.exe" (
    echo   ✓ VcXsrv found
    set VCXSRV_OK=1
) else (
    echo   ✗ VcXsrv not found
    set VCXSRV_OK=0
)

REM Check for Qt Designer
set QT_OK=0
for /d %%d in ("%USB_DRIVE%\tools\designer*") do (
    if exist "%%d\designer.exe" (
        echo   ✓ Qt Designer found
        set QT_OK=1
    )
)
if !QT_OK!==0 echo   ⚠ Qt Designer not found

REM Check for Eclipse
set ECLIPSE_OK=0
for /d %%d in ("%USB_DRIVE%\tools\eclipse*") do (
    if exist "%%d\eclipse.exe" (
        echo   ✓ Eclipse found
        set ECLIPSE_OK=1
    )
)
if !ECLIPSE_OK!==0 echo   ⚠ Eclipse not found

if !VCXSRV_OK!==0 (
    echo.
    echo VcXsrv is required for GUI support. Run setup_windows_tools.bat? (y/n)
    set /p setup_tools=""
    if /i "!setup_tools!"=="y" (
        if exist "%USB_DRIVE%\scripts\setup\setup_windows_tools.bat" (
            call "%USB_DRIVE%\scripts\setup\setup_windows_tools.bat"
        ) else (
            call scripts\setup\setup_windows_tools.bat
        )
    )
)

REM ============================================
REM Step 6: Launch development environment
REM ============================================
:launch
echo.
echo [Step 6/6] Ready to launch...
echo.
echo ================================================
echo   Setup Complete!
echo ================================================
echo.
echo Container runtime: %RUNTIME%
if !USB_MODE!==1 echo USB drive: %USB_DRIVE%
if !IMAGES_EXIST!==1 (
    echo Images loaded: ✓
) else (
    echo Images loaded: ✗ (add manually or rerun setup)
)
echo.
pause

REM Launch the main launcher
if !USB_MODE!==1 (
    if exist "%USB_DRIVE%\START_WINDOWS.bat" (
        call "%USB_DRIVE%\START_WINDOWS.bat"
    ) else (
        call START_WINDOWS.bat
    )
) else (
    call START_WINDOWS.bat
)
