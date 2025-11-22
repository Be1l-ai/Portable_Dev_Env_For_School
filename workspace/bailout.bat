@echo off
REM bailout.bat - Safely delete workspace after pushing
REM Only deletes if everything is committed and pushed

setlocal EnableDelayedExpansion

echo ========================================
echo   Bailout Script - Safe Deletion
echo ========================================
echo.

REM Get repo root
set "REPO_ROOT=%~dp0..\.."
cd /d "%REPO_ROOT%"

echo Running safety checks...
echo.

REM Check 1: Is there a remote?
echo [Check 1/3] Checking remote repository...
git remote get-url origin >nul 2>&1
if errorlevel 1 (
    echo X FAILED: No remote repository configured!
    echo.
    echo Cannot delete workspace without a backup remote.
    echo Add a remote first:
    echo   git remote add origin ^<your-repo-url^>
    pause
    exit /b 1
)

for /f "delims=" %%i in ('git remote get-url origin 2^>nul') do set "REMOTE_URL=%%i"
echo + PASSED: Remote configured ^(%REMOTE_URL%^)

REM Check 2: Any uncommitted changes?
echo [Check 2/3] Checking for uncommitted changes...
for /f %%i in ('git status --porcelain 2^>nul ^| find /c /v ""') do set "UNCOMMITTED=%%i"

if not "%UNCOMMITTED%"=="0" (
    echo X FAILED: You have uncommitted changes!
    echo.
    echo Uncommitted files:
    git status --short
    echo.
    echo Commit them first:
    echo   git add .
    echo   git commit -m "Your message"
    pause
    exit /b 1
)

echo + PASSED: No uncommitted changes

REM Check 3: Any unpushed commits?
echo [Check 3/3] Checking for unpushed commits...

REM Check if branch has upstream
git rev-parse --abbrev-ref @{u} >nul 2>&1
if errorlevel 1 (
    for /f "delims=" %%i in ('git branch --show-current') do set "BRANCH=%%i"
    echo X FAILED: Branch not pushed to remote!
    echo.
    echo Push your branch first:
    echo   git push -u origin !BRANCH!
    pause
    exit /b 1
)

REM Check for unpushed commits
for /f %%i in ('git rev-list @{u}..HEAD 2^>nul ^| find /c /v ""') do set "UNPUSHED=%%i"

if not "%UNPUSHED%"=="0" (
    echo X FAILED: You have %UNPUSHED% unpushed commit^(s^)!
    echo.
    echo Unpushed commits:
    git log @{u}..HEAD --oneline
    echo.
    echo Push them first:
    echo   git push
    pause
    exit /b 1
)

echo + PASSED: Everything is pushed

REM All checks passed
echo.
echo ========================================
echo   All Safety Checks Passed!
echo ========================================
echo.
echo Your work is safely backed up to:
echo   %REMOTE_URL%
echo.
echo This will DELETE the entire workspace directory:
echo   %REPO_ROOT%
echo.
set /p confirm="Type 'DELETE' to confirm: "

if /i not "%confirm%"=="DELETE" (
    echo Cancelled. Workspace not deleted.
    pause
    exit /b 0
)

echo.
echo Deleting workspace in 3 seconds...
timeout /t 1 >nul
echo 3...
timeout /t 1 >nul
echo 2...
timeout /t 1 >nul
echo 1...

REM Delete the entire directory (go up and delete)
cd ..
set "WORKSPACE_NAME=%~nx2"
rmdir /s /q "%REPO_ROOT%"

echo.
echo + Workspace deleted successfully!
echo.
echo Your code is safe at: %REMOTE_URL%
echo To get it back: git clone %REMOTE_URL%
echo.
pause
