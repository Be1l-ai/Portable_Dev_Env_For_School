# Dev Container Setup for VS Code

This folder contains scripts to set up VS Code Dev Container configurations for Python and Java development.

## What is Dev Containers?

Dev Containers lets you use VS Code on your host machine while running code inside Docker/Podman containers. This solves the problem of:
- ❌ No code editor inside containers
- ❌ No Python/Java modules outside containers

With Dev Containers:
- ✅ Code in VS Code with full IntelliSense
- ✅ Run/debug inside container with all modules
- ✅ Best of both worlds!

---

## Quick Start

### 1. Install VS Code Extension

Install **Dev Containers** extension:
- Open VS Code
- Press `Ctrl+Shift+X` (Extensions)
- Search: `ms-vscode-remote.remote-containers`
- Click Install

### 2. Make Sure Container Images Are Loaded

```bash
# Check if images exist
docker images | grep gui
# or
podman images | grep gui

# Should see:
# python-gui
# java-gui
```

If not loaded, run:
```bash
# From repo root
./start_linux.sh  # Linux
# or
START_WINDOWS.bat  # Windows
```

### 3. Run Setup Script

**Linux:**
```bash
# From repo root
chmod +x scripts/containers/setup_devcontainer.sh
./scripts/containers/setup_devcontainer.sh all
```

**Windows:**
```cmd
REM From repo root
scripts\containers\setup_devcontainer.bat all
```

This creates:
- `projects/python/.devcontainer/devcontainer.json`
- `projects/java/.devcontainer/devcontainer.json`

### 4. Open Project in Container

**For Python projects:**
1. Open `projects/python/` folder in VS Code
2. VS Code detects `.devcontainer/devcontainer.json`
3. Click "Reopen in Container" notification
   - Or press `F1` → "Dev Containers: Reopen in Container"
4. VS Code connects to `python-gui` container
5. Start coding with full Python + PyQt6 support!

**For Java projects:**
1. Open `projects/java/` folder in VS Code
2. Click "Reopen in Container"
3. VS Code connects to `java-gui` container
4. Start coding with full Java + Swing support!

---

## Script Options

```bash
# Setup both Python and Java
./setup_devcontainer.sh all

# Setup Python only
./setup_devcontainer.sh python

# Setup Java only
./setup_devcontainer.sh java
```

---

## What Gets Configured?

### Python Container (`projects/python/.devcontainer/`)

**Installed VS Code Extensions:**
- Python
- Pylance (IntelliSense)
- Debugpy (Debugging)
- Black Formatter
- Ruff (Linting)

**Settings:**
- Python path: `/usr/bin/python3`
- Format on save enabled
- Black formatter
- Pylint enabled

**Available Packages:**
- Python 3.12.3
- PyQt6 6.6.1
- debugpy, black, pyright, pylint, pytest, ipython
- 447 packages total

### Java Container (`projects/java/.devcontainer/`)

**Installed VS Code Extensions:**
- Java Extension Pack
- Maven
- Gradle
- Red Hat Java

**Settings:**
- Java home: `/usr/lib/jvm/java-21-openjdk-amd64`
- Maven path: `/usr/bin/mvn`
- Hot code replace enabled

**Available Tools:**
- OpenJDK 21.0.5
- Maven 3.8.7
- Gradle 4.4.1
- 456 packages total

---

## How It Works

1. **VS Code runs on host** - Your settings, themes, keyboard shortcuts
2. **Code executes in container** - Python/Java modules, libraries, tools
3. **Seamless integration** - IntelliSense, debugging, terminal all work inside container

```
┌─────────────────────────────┐
│   Your Computer (Host)      │
│                             │
│  ┌───────────────────────┐  │
│  │      VS Code          │  │
│  │  - Editor             │  │
│  │  - IntelliSense       │  │
│  │  - Extensions         │  │
│  └───────────┬───────────┘  │
│              │              │
│              │ Dev Container│
│              │ Extension    │
│              ▼              │
│  ┌───────────────────────┐  │
│  │   Docker/Podman       │  │
│  │  ┌─────────────────┐  │  │
│  │  │  python-gui     │  │  │
│  │  │  - Python 3.12  │  │  │
│  │  │  - PyQt6        │  │  │
│  │  │  - All modules  │  │  │
│  │  └─────────────────┘  │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

---

## Workflow Example

### Python GUI Development

```bash
# 1. Setup devcontainer
./scripts/containers/setup_devcontainer.sh python

# 2. Create a PyQt6 project
mkdir -p projects/python/my_gui_app
cd projects/python

# 3. Open in VS Code
code .

# 4. Reopen in Container (F1 → Dev Containers: Reopen in Container)

# 5. Create main.py
# VS Code now has full PyQt6 IntelliSense!
```

**main.py:**
```python
from PyQt6.QtWidgets import QApplication, QMainWindow, QLabel
import sys

app = QApplication(sys.argv)
window = QMainWindow()
window.setWindowTitle("My App")
label = QLabel("Hello World!", window)
window.show()
sys.exit(app.exec())
```

**Run with GUI:**
- Press `F5` to debug
- Or run in terminal: `python main.py`
- GUI appears on your screen (via VcXsrv on Windows, native X11 on Linux)

### Java Swing Development

```bash
# 1. Setup devcontainer
./scripts/containers/setup_devcontainer.sh java

# 2. Create a Java project
mkdir -p projects/java/MySwingApp
cd projects/java

# 3. Open in VS Code
code .

# 4. Reopen in Container

# 5. Create Main.java with full Java IntelliSense
```

---

## Troubleshooting

### "Container not found" error

**Solution:** Load container images first
```bash
# Check if images exist
docker images | grep gui

# If missing, load them
docker load -i images/python-gui.tar
docker load -i images/java-gui.tar
```

### VS Code can't connect to container

**Solution:** Check Docker/Podman is running
```bash
# Test Docker
docker ps

# Test Podman
podman ps
```

### Extensions not installing

**Solution:** Let it finish on first open (takes 1-2 minutes)
- VS Code downloads and installs extensions inside container
- Wait for "Dev Container: Ready" status

### No GUI display on Windows

**Solution:** Start VcXsrv first
```cmd
REM Start X server before opening container
START_WINDOWS.bat
REM Then use VS Code Dev Containers
```

### Import errors even in container

**Solution:** Restart VS Code's Python language server
- Press `F1`
- Type: "Python: Restart Language Server"

---

## Customization

Edit `projects/python/.devcontainer/devcontainer.json` or `projects/java/.devcontainer/devcontainer.json` to:
- Add more VS Code extensions
- Change settings
- Add environment variables
- Forward ports
- Run custom startup commands

Example:
```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "your-favorite-extension"
      ]
    }
  },
  "forwardPorts": [8000],
  "postCreateCommand": "pip install -r requirements.txt"
}
```

---

## Alternative: Command Line Development

If you prefer not to use VS Code Dev Containers, you can still develop in the terminal:

```bash
# Start container
./start_linux.sh  # or START_WINDOWS.bat

# Install nano/vim in container (temporary)
apt-get update && apt-get install -y nano vim

# Edit code
nano projects/python/main.py

# Run code
python projects/python/main.py
```

But **Dev Containers is highly recommended** for the best development experience!
