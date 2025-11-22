@echo off
REM cleanup.bat - Convert setup repo into your workspace
REM Removes setup files, keeps images/projects/tools

setlocal EnableDelayedExpansion

echo ========================================
echo   Workspace Cleanup Script
echo ========================================
echo.
echo This will:
echo   1. Remove git remote (disconnect from setup repo)
echo   2. Delete setup scripts and documentation
echo   3. Keep only: images/, projects/, tools/
echo   4. Optionally connect to YOUR project repo
echo.
echo WARNING: This cannot be undone!
echo.
set /p confirm="Continue? (yes/no): "

if /i not "%confirm%"=="yes" (
    echo Cancelled.
    exit /b 0
)

REM Get repo root
set "REPO_ROOT=%~dp0..\.."
cd /d "%REPO_ROOT%"

echo.
echo [1/5] Removing git remote...
git remote remove origin 2>nul
if errorlevel 1 (
    echo   No remote to remove
) else (
    echo   + Removed origin remote
)

echo.
echo [2/5] Deleting setup files...

REM Delete setup files
if exist "auto-setup.sh" del /q "auto-setup.sh" && echo   + Deleted auto-setup.sh
if exist "auto-setup.bat" del /q "auto-setup.bat" && echo   + Deleted auto-setup.bat
if exist "START_WINDOWS.bat" del /q "START_WINDOWS.bat" && echo   + Deleted START_WINDOWS.bat
if exist "start_linux.sh" del /q "start_linux.sh" && echo   + Deleted start_linux.sh
if exist "README.md" del /q "README.md" && echo   + Deleted README.md
if exist ".gitignore" del /q ".gitignore" && echo   + Deleted old .gitignore

REM Delete directories
if exist "scripts\" rmdir /s /q "scripts" && echo   + Deleted scripts\
if exist "docu\" rmdir /s /q "docu" && echo   + Deleted docu\
if exist "config\" rmdir /s /q "config" && echo   + Deleted config\
if exist ".github\" rmdir /s /q ".github" && echo   + Deleted .github\

echo.
echo [3/5] Creating new .gitignore...

(
echo # Workspace .gitignore - Only track your projects
echo.
echo # Ignore container images ^(too large for Git^)
echo images/*.tar
echo.
echo # Ignore tools binaries ^(download separately^)
echo tools/
echo vcxsrv/
echo podman/
echo.
echo # OS files
echo .DS_Store
echo Thumbs.db
echo desktop.ini
echo.
echo # IDE files ^(keep devcontainer^)
echo .vscode/
echo !.devcontainer/
echo.
echo # Temporary files
echo *.log
echo *.tmp
echo *~
) > .gitignore

echo   + Created new .gitignore

echo.
echo [4/5] Current workspace contents:
dir /b

echo.
echo [5/5] Connect to your remote repo?
echo.
set /p connect_remote="Connect to your project repo? (y/n): "

if /i "%connect_remote%"=="y" (
    echo.
    set /p remote_url="Enter your Git remote URL (e.g., https://github.com/username/myproject.git): "
    
    if not "!remote_url!"=="" (
        git remote add origin "!remote_url!"
        echo + Connected to: !remote_url!
        echo.
        echo To push your work:
        echo   git add .
        echo   git commit -m "Initial commit"
        echo   git push -u origin main
    ) else (
        echo No URL provided, skipping remote setup.
    )
) else (
    echo Skipped remote setup. You can add it later with:
    echo   git remote add origin ^<your-repo-url^>
)

echo.
echo ========================================
echo   Cleanup Complete!
echo ========================================
echo.
echo Your workspace now contains:
echo   - projects/    ^(your code^)
echo   - images/      ^(container images^)
echo   - tools/       ^(optional GUI tools^)
echo.
echo Next steps:
echo   1. Start coding in projects\python\ or projects\java\
echo   2. Commit your work: git add . ^&^& git commit -m "message"
echo   3. Push to remote: git push
echo.
echo When done, run: scripts\workspace\bailout.bat
echo.
pause
