# Portable Development Environment for School

**A lightweight, portable Python + Java GUI development environment that works on restricted Windows lab PCs and Linux without admin rights.**

## Why This Exists

- School computers have restrictive policies (no admin, limited software)
- GitHub Codespaces doesn't support GUI applications well
- Need a consistent dev environment that works on both Windows and Linux
- Want to develop Python (PyQt6) and Java (Swing) GUI applications
- Must be portable (USB or Git-based) and work offline after initial setup

## What You Get

- 🐍 **Python 3.12** with PyQt6 for GUI development
- ☕ **Java 21** with Maven/Gradle for Swing development
- 📝 **Neovim** with LSP, debugger, and autocomplete (Kickstart.nvim)
- 🎨 **Qt Designer** for visual PyQt6 UI design
- 🖼️ **Eclipse + WindowBuilder** for visual Swing UI design
- 🐳 **Podman** containers (works without admin/Docker)
- 🪟 **VcXsrv** X11 server for GUI support on Windows
- 📦 **Git** for version control with GitHub/GitLab

**Total size:** ~4.3 GB (fits on 8 GB USB stick or can be cloned via Git)

---

## Two Setup Options

### Option 1: USB Setup (Recommended for frequent use)

Build everything once on a USB stick, then plug and play on any computer.

👉 **[USB Setup Guide](USB_SETUP.md)**

**Pros:**
- Works completely offline after initial setup
- Fastest startup (15 seconds)
- No need to download anything on school PCs
- Can use on computers without internet

**Cons:**
- Requires 8 GB USB stick (~$10)
- Initial build takes 20 minutes

---

### Option 2: Git-Based Setup (Recommended for flexibility)

Clone the environment from Git whenever you need it, download container images separately.

👉 **[Git Setup Guide](GIT_SETUP.md)**

**Pros:**
- No USB stick needed
- Easy to update (`git pull`)
- Can sync code changes automatically
- Works on USB-blocked computers

**Cons:**
- First-time setup downloads ~4.2 GB
- Requires internet for initial clone
- Need to clean up afterward on shared PCs

---

## Quick Start (Daily Use)

Once set up, using the environment is simple:

### Windows (School Lab PC)

```cmd
REM With USB:
E:
START_WINDOWS.bat

REM With Git:
cd C:\Temp\dev
START_WINDOWS.bat
```

Choose Python (`p`) or Java (`j`) and start coding!

### Linux (Home Machine)

```bash
cd /path/to/dev/environment
./start_linux.sh
```

Choose Python (`p`) or Java (`j`) and start coding!

👉 **[Daily Usage Guide](QUICKSTART.md)**

---

## Features

### Development Tools

- **Python 3.12** with pip and PyQt6
- **Java 21 (OpenJDK)** with Maven and Gradle
- **Neovim 0.10** with Kickstart.nvim configuration
  - LSP support (Python: pyright, Java: jdtls)
  - Debugger integration (debugpy, jdb)
  - Auto-completion and formatting
  - Fuzzy finding, syntax highlighting, and themes
- **Git** for version control

### GUI Development

- **PyQt6** for Python GUI applications
- **Qt Designer 6.8** for visual UI design
- **Java Swing** for Java GUI applications
- **Eclipse WindowBuilder** for visual Swing design
- **X11 forwarding** - GUI apps appear as native windows

### Portability

- **No admin rights required** - runs in user space
- **Works offline** - everything is self-contained
- **Cross-platform** - same environment on Windows and Linux
- **Containerized** - isolated from host system
- **Version controlled** - can sync via Git

---

## Project Structure

```
Portable_Dev_Env_For_School/
├── START_WINDOWS.bat          # Windows launcher
├── start_linux.sh             # Linux launcher
├── download_images.sh         # Helper to download containers (Linux)
├── download_images.bat        # Helper to download containers (Windows)
├── build_images.sh            # Build containers from scratch
├── .gitignore                 # Excludes large binaries from Git
│
├── Documentation/
│   ├── README.md              # This file
│   ├── USB_SETUP.md           # USB setup instructions
│   ├── GIT_SETUP.md           # Git setup instructions
│   ├── QUICKSTART.md          # Daily usage guide
│   └── INSTRUCTIONS.md        # Original requirements
│
├── podman/                    # Podman portable binaries (excluded from Git)
├── vcxsrv/                    # VcXsrv X11 server (excluded from Git)
├── tools/                     # Development tools (excluded from Git)
│   ├── nvim-portable/         # Neovim portable
│   ├── designer/              # Qt Designer
│   └── eclipse-portable/      # Eclipse + WindowBuilder
│
├── images/                    # Container images (excluded from Git)
│   ├── python-gui.tar         # Python container (~1.8 GB)
│   └── java-gui.tar           # Java container (~1.6 GB)
│
├── projects/                  # Your code goes here
│   ├── python/                # Python projects
│   └── java/                  # Java projects
│
└── config/                    # Shared configurations
    ├── nvim/                  # Neovim config (Kickstart.nvim)
    └── .ssh/                  # SSH keys for Git (optional)
```

---

## System Requirements

### Windows
- Windows 10/11 (no admin required)
- WSL 2 enabled (usually already enabled on school PCs)
- 4.5 GB free disk space
- USB port (for USB setup) or internet (for Git setup)

### Linux
- Any modern Linux distro (Ubuntu, Fedora, etc.)
- Podman installed (`apt install podman` or `dnf install podman`)
- 4.5 GB free disk space
- X11 display server (usually pre-installed)

---

## Documentation

| Document | Description |
|----------|-------------|
| [USB_SETUP.md](USB_SETUP.md) | Complete guide to building the USB setup |
| [GIT_SETUP.md](GIT_SETUP.md) | Complete guide to using Git-based setup |
| [QUICKSTART.md](QUICKSTART.md) | Daily usage instructions and tips |
| [INSTRUCTIONS.md](INSTRUCTIONS.md) | Original project requirements |

---

## Helper Scripts

| Script | Platform | Purpose |
|--------|----------|---------|
| `START_WINDOWS.bat` | Windows | Start development environment |
| `start_linux.sh` | Linux | Start development environment |
| `build_images.sh` | Linux | Build container images from scratch |
| `download_images.sh` | Linux | Download pre-built container images |
| `download_images.bat` | Windows | Download pre-built container images |

---

## Example Projects

### Python + PyQt6

```python
from PyQt6.QtWidgets import QApplication, QMainWindow, QLabel
import sys

app = QApplication(sys.argv)
window = QMainWindow()
window.setWindowTitle("Hello PyQt6")
label = QLabel("Hello from Portable Dev Env!", window)
label.setGeometry(50, 50, 300, 50)
window.setGeometry(100, 100, 400, 200)
window.show()
sys.exit(app.exec())
```

### Java + Swing

```java
import javax.swing.*;

public class Main {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            JFrame frame = new JFrame("Hello Swing");
            frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            frame.add(new JLabel("Hello from Portable Dev Env!", SwingConstants.CENTER));
            frame.setSize(400, 200);
            frame.setVisible(true);
        });
    }
}
```

---

## Troubleshooting

### GUI windows not appearing (Windows)
- Check if VcXsrv is running (system tray icon)
- Restart: `taskkill /IM vcxsrv.exe /F` then run `START_WINDOWS.bat` again

### Podman won't start (Windows)
- Ensure WSL 2 is enabled: `wsl --install` in PowerShell
- Check Podman machine status: `podman machine ls`
- Restart machine: `podman machine stop && podman machine start`

### Container images missing
- Run `download_images.sh` or `download_images.bat`
- Or build from scratch: `./build_images.sh`

### Neovim LSP not working
- Inside Neovim: `:LspInfo` to check status
- Install missing servers: `:Mason`
- Check health: `:checkhealth`

More troubleshooting tips in [QUICKSTART.md](QUICKSTART.md).

---

## Acknowledgments

Built with:
- [Podman](https://podman.io/) - Container runtime
- [VcXsrv](https://sourceforge.net/projects/vcxsrv/) - X11 server for Windows
- [Neovim](https://neovim.io/) - Modern text editor
- [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) - Neovim configuration
- [PyQt6](https://www.riverbankcomputing.com/software/pyqt/) - Python GUI framework
- [Ubuntu](https://ubuntu.com/) - Container base image
