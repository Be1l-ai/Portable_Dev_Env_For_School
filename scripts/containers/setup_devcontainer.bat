@echo off
REM setup_devcontainer.bat - Create VS Code Dev Container configurations
REM Usage: setup_devcontainer.bat [python|java|all]

setlocal EnableDelayedExpansion

set "SETUP_TARGET=%~1"
if "%SETUP_TARGET%"=="" set "SETUP_TARGET=all"

echo ===================================
echo   Dev Container Setup Script
echo ===================================
echo.

REM Get script directory and navigate to repo root
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%..\..\"

REM Setup Python devcontainer
if /i "%SETUP_TARGET%"=="python" goto :setup_python
if /i "%SETUP_TARGET%"=="all" goto :setup_python
goto :check_java

:setup_python
echo Setting up Python Dev Container...

if not exist "projects\python\.devcontainer" mkdir "projects\python\.devcontainer"

(
echo {
echo   "name": "Python PyQt6 Development",
echo   "image": "python-gui",
echo   "workspaceFolder": "/workspace",
echo   
echo   "mounts": [
echo     "source=${localWorkspaceFolder},target=/workspace,type=bind"
echo   ],
echo   
echo   "customizations": {
echo     "vscode": {
echo       "extensions": [
echo         "ms-python.python",
echo         "ms-python.vscode-pylance",
echo         "ms-python.debugpy",
echo         "ms-python.black-formatter",
echo         "charliermarsh.ruff"
echo       ],
echo       "settings": {
echo         "python.defaultInterpreterPath": "/usr/bin/python3",
echo         "python.formatting.provider": "black",
echo         "python.linting.enabled": true,
echo         "python.linting.pylintEnabled": true,
echo         "editor.formatOnSave": true
echo       }
echo     }
echo   },
echo   
echo   "forwardPorts": [],
echo   
echo   "postCreateCommand": "pip3 list",
echo   
echo   "remoteUser": "root"
echo }
) > "projects\python\.devcontainer\devcontainer.json"

echo   + Created projects\python\.devcontainer\devcontainer.json
echo.

if /i "%SETUP_TARGET%"=="python" goto :done

:check_java
REM Setup Java devcontainer
if /i "%SETUP_TARGET%"=="java" goto :setup_java
if /i "%SETUP_TARGET%"=="all" goto :setup_java
goto :invalid_target

:setup_java
echo Setting up Java Dev Container...

if not exist "projects\java\.devcontainer" mkdir "projects\java\.devcontainer"

(
echo {
echo   "name": "Java Swing Development",
echo   "image": "java-gui",
echo   "workspaceFolder": "/workspace",
echo   
echo   "mounts": [
echo     "source=${localWorkspaceFolder},target=/workspace,type=bind"
echo   ],
echo   
echo   "customizations": {
echo     "vscode": {
echo       "extensions": [
echo         "vscjava.vscode-java-pack",
echo         "vscjava.vscode-maven",
echo         "vscjava.vscode-gradle",
echo         "redhat.java"
echo       ],
echo       "settings": {
echo         "java.home": "/usr/lib/jvm/java-21-openjdk-amd64",
echo         "java.configuration.runtimes": [
echo           {
echo             "name": "JavaSE-21",
echo             "path": "/usr/lib/jvm/java-21-openjdk-amd64",
echo             "default": true
echo           }
echo         ],
echo         "maven.executable.path": "/usr/bin/mvn",
echo         "java.debug.settings.hotCodeReplace": "auto"
echo       }
echo     }
echo   },
echo   
echo   "forwardPorts": [],
echo   
echo   "postCreateCommand": "java -version && mvn -version",
echo   
echo   "remoteUser": "root"
echo }
) > "projects\java\.devcontainer\devcontainer.json"

echo   + Created projects\java\.devcontainer\devcontainer.json
echo.

goto :done

:invalid_target
echo Invalid target: %SETUP_TARGET%
echo Usage: setup_devcontainer.bat [python^|java^|all]
exit /b 1

:done
echo ===================================
echo   Dev Container Setup Complete!
echo ===================================
echo.
echo To use with VS Code:
echo   1. Install 'Dev Containers' extension (ms-vscode-remote.remote-containers)
echo   2. Make sure container images are loaded: docker images or podman images
echo   3. Open projects\python\ or projects\java\ in VS Code
echo   4. Press F1 -^> 'Dev Containers: Reopen in Container'
echo   5. VS Code will connect to your container and you can code with full IntelliSense!
echo.
pause
