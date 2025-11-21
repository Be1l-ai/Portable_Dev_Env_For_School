@echo off
REM setup_windows_tools.bat - Setup all Windows-only tools on USB
REM Run this script on a Windows PC to add Qt Designer, Eclipse, and VcXsrv to your USB

echo ========================================
echo   Windows Tools Setup for USB
echo ========================================
echo.
echo This script helps you add Windows-only tools to your USB:
echo   - VcXsrv (X11 server for GUI support)
echo   - Qt Designer (Visual PyQt6 UI designer)
echo   - Eclipse (Optional - Java GUI designer)
echo.

REM Detect USB drive
set USB_DRIVE=
for %%d in (D E F G H I J K) do (
    if exist %%d:\START_WINDOWS.bat (
        set USB_DRIVE=%%d:
        goto :found_usb
    )
)

echo ERROR: Could not find USB drive automatically.
echo.
set /p USB_DRIVE="Enter your USB drive letter (e.g., E): "
if not exist "%USB_DRIVE%:\START_WINDOWS.bat" (
    echo.
    echo ERROR: USB drive not found or invalid.
    echo Make sure your USB is plugged in and contains START_WINDOWS.bat
    pause
    exit /b 1
)

:found_usb
echo Found USB at %USB_DRIVE%
echo.

REM ============================================
REM Setup VcXsrv
REM ============================================
echo [1/3] Setting up VcXsrv...
echo.

if exist "%USB_DRIVE%\vcxsrv\vcxsrv.exe" (
    echo   ✓ VcXsrv already on USB
) else (
    echo VcXsrv not found on USB.
    echo.
    if exist "C:\Program Files\VcXsrv\vcxsrv.exe" (
        echo Found VcXsrv installed on this PC!
        set /p copy_vcxsrv="Copy VcXsrv to USB? (y/n): "
        if /i "%copy_vcxsrv%"=="y" (
            echo Copying VcXsrv to USB...
            if not exist "%USB_DRIVE%\vcxsrv\" mkdir "%USB_DRIVE%\vcxsrv"
            xcopy "C:\Program Files\VcXsrv\*" "%USB_DRIVE%\vcxsrv\" /E /I /Y >nul
            echo   ✓ VcXsrv copied to USB
        )
    ) else (
        echo VcXsrv not installed on this PC.
        echo.
        echo Options:
        echo   [1] Download and install now
        echo   [2] Skip for now
        echo.
        set /p vcxsrv_choice="Choose (1/2): "
        if "%vcxsrv_choice%"=="1" (
            echo Opening VcXsrv download page...
            start https://sourceforge.net/projects/vcxsrv/files/latest/download
            echo.
            echo After installing VcXsrv, run this script again to copy it to USB.
        ) else (
            echo   ⚠ Skipping VcXsrv
        )
    )
)

echo.

REM ============================================
REM Setup Qt Designer
REM ============================================
echo [2/3] Setting up Qt Designer...
echo.

if exist "%USB_DRIVE%\tools\designer\designer.exe" (
    echo   ✓ Qt Designer already on USB
) else (
    echo Qt Designer not found on USB.
    echo.
    echo Qt Designer requires Qt installation (large download).
    echo.
    echo Options:
    echo   [1] I have Qt installed - copy Designer to USB
    echo   [2] Download Qt now (opens browser)
    echo   [3] Skip for now (you can code without visual designer)
    echo.
    set /p qt_choice="Choose (1/2/3): "
    
    if "%qt_choice%"=="1" (
        echo.
        echo Common Qt Designer locations:
        echo   C:\Qt\6.8.0\mingw_64\bin\designer.exe
        echo   C:\Qt\6.7.0\mingw_64\bin\designer.exe
        echo   C:\Program Files\Qt\*\bin\designer.exe
        echo.
        set /p qt_path="Enter path to designer.exe (or press Enter to search): "
        
        if "%qt_path%"=="" (
            REM Try to find Qt automatically
            for %%d in (C:\Qt\6.*.0\mingw_64\bin\designer.exe) do (
                if exist "%%d" (
                    set qt_path=%%d
                    goto :found_qt
                )
            )
            echo Could not find Qt Designer automatically.
            goto :skip_qt
        )
        
        :found_qt
        if exist "%qt_path%" (
            echo Found: %qt_path%
            echo.
            echo Copying Qt Designer to USB...
            if not exist "%USB_DRIVE%\tools\designer\" mkdir "%USB_DRIVE%\tools\designer"
            
            REM Copy designer.exe
            copy "%qt_path%" "%USB_DRIVE%\tools\designer\" >nul
            
            REM Copy required DLLs from same directory
            for %%f in ("%qt_path%\..\*.dll") do (
                copy "%%f" "%USB_DRIVE%\tools\designer\" >nul 2>&1
            )
            
            echo   ✓ Qt Designer copied to USB
            echo   Note: Some DLLs copied - test it to ensure it works
        ) else (
            echo Designer not found at that path.
        )
        
    ) else if "%qt_choice%"=="2" (
        echo Opening Qt download page...
        start https://www.qt.io/download-qt-installer
        echo.
        echo After installing Qt, run this script again to copy Designer to USB.
    ) else (
        :skip_qt
        echo   ⚠ Skipping Qt Designer
        echo   (You can still code PyQt6 manually with a text editor)
    )
)

echo.

REM ============================================
REM Setup Eclipse (Optional)
REM ============================================
echo [3/3] Setting up Eclipse (optional)...
echo.

if exist "%USB_DRIVE%\tools\eclipse-portable\eclipse.exe" (
    echo   ✓ Eclipse already on USB
) else (
    echo Eclipse not found on USB.
    echo.
    echo Eclipse is optional - only needed for visual Java Swing designer.
    echo.
    echo Options:
    echo   [1] Download Eclipse portable now (opens browser)
    echo   [2] Skip for now (you can code Java without visual designer)
    echo.
    set /p eclipse_choice="Choose (1/2): "
    
    if "%eclipse_choice%"=="1" (
        echo Opening Eclipse download page...
        start https://www.eclipse.org/downloads/
        echo.
        echo Download "Eclipse IDE for Java Developers"
        echo Extract to: %USB_DRIVE%\tools\eclipse-portable\
        echo Then you'll have: %USB_DRIVE%\tools\eclipse-portable\eclipse.exe
    ) else (
        echo   ⚠ Skipping Eclipse
    )
)

echo.
echo ========================================
echo   Setup Summary
echo ========================================
echo.

if exist "%USB_DRIVE%\vcxsrv\vcxsrv.exe" (
    echo   ✓ VcXsrv ready
) else (
    echo   ✗ VcXsrv missing - GUI apps won't work on Windows
)

if exist "%USB_DRIVE%\tools\designer\designer.exe" (
    echo   ✓ Qt Designer ready
) else (
    echo   ⚠ Qt Designer missing - can still code PyQt6 manually
)

if exist "%USB_DRIVE%\tools\eclipse-portable\eclipse.exe" (
    echo   ✓ Eclipse ready
) else (
    echo   ⚠ Eclipse missing - can still code Java Swing manually
)

echo.
echo USB is ready for use!
echo Run %USB_DRIVE%\START_WINDOWS.bat to start coding.
echo.
pause
