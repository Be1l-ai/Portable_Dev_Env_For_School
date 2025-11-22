# USB Setup Guide

**Build a complete Python + Java GUI development environment on a USB stick. Works on Windows and Linux school PCs without admin rights.**

## What You Get

- **Python 3.12.3** + PyQt6 + 447 packages + debugger
- **Java JDK 21** + Maven + Gradle + 456 packages
- **Neovim** with LSP, autocomplete, debugger
- **VcXsrv** for Windows GUI support
- **All on USB** - plug and play on any PC

**Total Size:** ~2.5 GB (2.2 GB images + 300 MB tools)

---

## Quick Build (Use Automation Scripts)

**Prerequisites:**
- 8 GB USB stick (formatted as exFAT)
- Linux machine with internet (for building)
- 15-20 minutes

**Build Steps:**

```bash
# 1. Clone this repository
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
cd Portable_Dev_Env_For_School

# 2. Mount your USB stick
# Usually auto-mounts at /run/media/$USER/DEVUSB or /media/$USER/DEVUSB

# 3. Build container images
scripts/build/build_images.sh all

# This creates:
# - images/python-gui.tar (1.1 GB, 447 packages)
# - images/java-gui.tar (1.1 GB, 456 packages)
# Build time: 10-15 minutes

# 4. Copy everything to USB
cp -r . /run/media/$USER/DEVUSB/

# 5. Done! Test it:
cd /run/media/$USER/DEVUSB
./start_linux.sh
```

**What the build script does:**
- ✅ Installs Podman (if not installed)
- ✅ Builds Python container (Python 3.12.3 + PyQt6 + all dev tools)
- ✅ Builds Java container (JDK 21 + Maven + Gradle)
- ✅ Saves as portable .tar files
- ✅ All packages included (447 Python, 456 Java)

---

## USB Structure

After building, your USB will have:

```
USB:/
├── auto-setup.bat           ← Run once on new Windows PC
├── auto-setup.sh            ← Run once on new Linux PC
├── START_WINDOWS.bat        ← Daily launcher (Windows)
├── start_linux.sh           ← Daily launcher (Linux)
├── images/
│   ├── python-gui.tar       ← 1.1 GB (Python + PyQt6)
│   └── java-gui.tar         ← 1.1 GB (Java + Maven)
├── projects/
│   ├── python/              ← Your Python projects
│   └── java/                ← Your Java projects
├── config/                  ← Neovim config, SSH keys
├── vcxsrv/                  ← X server for Windows (add later)
├── tools/                   ← Qt Designer, Eclipse (optional)
└── scripts/
    ├── build/               ← build_images.sh, download_images.sh
    └── setup/               ← setup_school_pc.bat, setup_windows_tools.bat
```

---

## Using on Windows School PC

**First Time Setup (5-10 minutes):**

```cmd
REM 1. Plug in USB (e.g., E: drive)
E:

REM 2. Run auto-setup (handles everything)
auto-setup.bat

REM What it does:
REM - Checks if Docker/Podman installed
REM - Offers to install WSL2+Docker if missing
REM - Loads container images from USB
REM - Installs VcXsrv (X server for GUI)
REM - Launches START_WINDOWS.bat
```

**Daily Use (15 seconds):**

```cmd
E:
START_WINDOWS.bat
```

---

## Using on Linux

**First Time Setup:**

```bash
# 1. Mount USB
cd /run/media/$USER/DEVUSB

# 2. Run auto-setup
./auto-setup.sh

# What it does:
# - Checks for Podman
# - Loads images from USB
# - Launches containers
```

**Daily Use:**

```bash
cd /run/media/$USER/DEVUSB
./start_linux.sh
```

---

## Adding Windows Tools (Optional)

VcXsrv, Qt Designer, and Eclipse are optional but recommended for Windows:

```cmd
REM Run on any Windows PC with your USB plugged in
E:
scripts\setup\setup_windows_tools.bat

REM This downloads and adds to USB:
REM - VcXsrv (X server, ~40 MB) - Required for GUI
REM - Qt Designer standalone (~250 MB) - Optional
REM - Eclipse with WindowBuilder (~900 MB) - Optional
```

**Alternative:** Download manually and extract to USB:
- **VcXsrv:** https://sourceforge.net/projects/vcxsrv/files/latest/download
- **Qt Designer:** https://www.qt.io/download (standalone version)
- **Eclipse:** https://www.eclipse.org/downloads/ (Java edition)

---

## Manual Build Steps (Advanced)

If you prefer to build everything manually instead of using automation scripts:

### 1. Format USB Drive

```bash
# Find your USB device
lsblk

# Format as exFAT (works on both Linux and Windows)
sudo mkfs.exfat -n DEVUSB /dev/sdX1

# Mount USB
# Usually auto-mounts at /run/media/$USER/DEVUSB
```

### 2. Build Container Images Manually

```bash
cd /run/media/$USER/DEVUSB

# Python container
podman build -t python-gui -f - . <<'DOCKERFILE'
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    libxcb-xinerama0 libxcb-cursor0 libxkbcommon-x11-0 \
    libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
    libxcb-randr0 libxcb-render-util0 libxcb-shape0 \
    fonts-dejavu-core git curl nano vim \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN pip3 install --break-system-packages \
    PyQt6==6.6.1 PyQt6-Qt6==6.6.1 PyQt6-sip==13.6.0 \
    debugpy black pyright pylint pytest ipython
WORKDIR /workspace
CMD ["/bin/bash"]
DOCKERFILE

podman save python-gui -o images/python-gui.tar

# Java container
podman build -t java-gui -f - . <<'DOCKERFILE'
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk maven gradle \
    libxext6 libxrender1 libxtst6 libxi6 \
    libxrandr2 libfreetype6 fontconfig fonts-dejavu-core \
    git curl nano vim \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
WORKDIR /workspace
CMD ["/bin/bash"]
DOCKERFILE

podman save java-gui -o images/java-gui.tar
```

### 3. Add Optional Tools

```bash
# Neovim portable
wget https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz
mkdir -p tools/nvim-portable
tar xzf nvim-linux64.tar.gz --strip-components=1 -C tools/nvim-portable/
rm nvim-linux64.tar.gz

# Kickstart.nvim config
git clone https://github.com/nvim-lua/kickstart.nvim.git config/nvim
```

### 4. Create Sample Projects

```bash
# Python PyQt6 sample
mkdir -p projects/python/hello_pyqt
cat > projects/python/hello_pyqt/main.py <<'EOF'
from PyQt6.QtWidgets import QApplication, QMainWindow, QLabel
import sys

app = QApplication(sys.argv)
window = QMainWindow()
window.setWindowTitle("Hello PyQt6")
label = QLabel("Hello from USB!", window)
label.setGeometry(50, 50, 300, 50)
window.setGeometry(100, 100, 400, 200)
window.show()
sys.exit(app.exec())
EOF

# Java Swing sample
mkdir -p projects/java/HelloSwing
cat > projects/java/HelloSwing/Main.java <<'EOF'
import javax.swing.*;

public class Main {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            JFrame frame = new JFrame("Hello Swing");
            frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            frame.add(new JLabel("Hello from USB!", SwingConstants.CENTER));
            frame.setSize(400, 200);
            frame.setVisible(true);
        });
    }
}
EOF
```

### 5. Copy Repository Files

```bash
# Clone repo to get scripts
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git temp
cp -r temp/* /run/media/$USER/DEVUSB/
rm -rf temp
```

---

## Troubleshooting

### USB won't mount on Windows
- Format as **exFAT** (not ext4 or NTFS)
- Windows natively supports exFAT

### Podman/Docker not installed on school PC
- Run `auto-setup.bat` - it offers to install WSL2+Docker
- Or ask IT to install Docker Desktop/Podman Desktop

### Container images too large
- Normal sizes: python-gui.tar (1.1 GB), java-gui.tar (1.1 GB)
- Total: 2.2 GB for full development environments with all packages

### GUI apps won't display on Windows
- VcXsrv must be running (check system tray)
- Run `auto-setup.bat` to install VcXsrv
- Or manually run `scripts\setup\setup_windows_tools.bat`

### Images already loaded error
- If you've used this USB before, images may already be in Docker/Podman
- Safe to ignore, or use `docker images` / `podman images` to check

---

## Build Time Summary

| Task | Time |
|------|------|
| Format USB | 2 min |
| Build Python image | 5-7 min |
| Build Java image | 5-7 min |
| Copy files | 1 min |
| **Total** | **15-20 min** |

**Daily usage time:** 15 seconds (just run START_WINDOWS.bat or start_linux.sh)
