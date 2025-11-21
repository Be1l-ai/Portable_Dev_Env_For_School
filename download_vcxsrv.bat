@echo off
REM download_vcxsrv.bat - Download VcXsrv portable to USB (run on Windows)
REM This helps you set up VcXsrv for GUI support

echo ========================================
echo   VcXsrv Download Helper
echo ========================================
echo.
echo VcXsrv provides GUI (X11) support for Windows.
echo This allows GUI apps from Linux containers to display on Windows.
echo.
echo Two options:
echo   [1] Download installer and extract manually
echo   [2] Install VcXsrv on this PC, then copy to USB
echo.
set /p choice="Choose (1/2): "

if "%choice%"=="1" (
    echo.
    echo Opening VcXsrv download page in browser...
    start https://sourceforge.net/projects/vcxsrv/files/latest/download
    echo.
    echo After download:
    echo   1. Install VcXsrv normally on this PC
    echo   2. Copy "C:\Program Files\VcXsrv\*" to USB vcxsrv folder
    echo   3. Delete local installation if you want
    pause
) else if "%choice%"=="2" (
    echo.
    echo Step-by-step:
    echo   1. Download from: https://sourceforge.net/projects/vcxsrv/
    echo   2. Install VcXsrv normally (Next, Next, Install)
    echo   3. Run this script again to copy to USB
    echo.
    set /p installed="Is VcXsrv installed? (y/n): "
    
    if /i "%installed%"=="y" (
        if exist "C:\Program Files\VcXsrv\vcxsrv.exe" (
            echo.
            echo Found VcXsrv installation!
            echo.
            set /p usb_drive="Enter USB drive letter (e.g., E): "
            
            if not exist "%usb_drive%:\vcxsrv\" mkdir "%usb_drive%:\vcxsrv"
            
            echo Copying VcXsrv files to %usb_drive%:\vcxsrv\...
            xcopy "C:\Program Files\VcXsrv\*" "%usb_drive%:\vcxsrv\" /E /I /Y
            
            echo.
            echo ✓ VcXsrv copied to USB successfully!
            echo.
            echo You can now uninstall VcXsrv from this PC if you want.
            echo The portable version on USB is all you need.
        ) else (
            echo.
            echo VcXsrv not found in "C:\Program Files\VcXsrv\"
            echo Please install it first.
        )
    )
    pause
) else (
    echo Invalid choice
    pause
)
