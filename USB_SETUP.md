# USB Setup Guide - Portable Dev Environment

**Build a complete Python + Java GUI development environment on an 8GB USB stick that works on Windows and Linux without admin rights or internet.**

## Final Size: ~4.3 GB

## What You Get

```
USB root/
├── START_WINDOWS.bat          ← Double-click on school Windows
├── start_linux.sh             ← Run on your home Linux
├── podman/                    ← Podman portable (Windows + Linux binaries, ~300 MB)
├── vcxsrv/                    ← VcXsrv X11 server for Windows (~40 MB)
├── images/                    ← 2 pre-built container images (Python + Java, ~3.2 GB total)
│   ├── python-gui.tar
│   └── java-gui.tar
├── tools/
│   ├── nvim-portable/         ← Neovim 0.10 portable with Kickstart.nvim config
│   ├── designer.exe           ← Standalone Qt6 Designer portable (~250 MB)
│   └── eclipse-portable/      ← Tiny Eclipse 2025-09 JE only + WindowBuilder (~900 MB)
├── projects/                  ← Put your repos here (git already works)
│   ├── python/
│   └── java/
└── config/                    ← Shared Neovim config (LSP, debugger, autocomplete, themes)
```

## Prerequisites

- **8 GB USB stick** (or larger)
- **Linux machine** for building (Ubuntu/Debian/Fedora)
- **~20 minutes** of time
- **~5 GB temporary disk space** during build

## Step-by-Step Build Instructions

### 1. Format USB Drive

Format your USB stick as **exFAT** (works on both Linux and Windows):

```bash
# Find your USB device (e.g., /dev/sdb1)
lsblk

# Format as exFAT with label "DEVUSB"
sudo mkfs.exfat -n DEVUSB /dev/sdX1

# Or use your file manager: Right-click → Format → exFAT + label "DEVUSB"
```

### 2. Mount USB and Create Directory Structure

```bash
# Mount USB (usually auto-mounts at /run/media/$USER/DEVUSB or /media/$USER/DEVUSB)
cd /run/media/$USER/DEVUSB   # or wherever it mounts

# Create folders
mkdir -p podman vcxsrv tools images projects/python projects/java config
```

### 3. Install Podman

**Two approaches depending on your school PC permissions:**

#### Option A: School PC Allows Podman (Recommended)

If your school PCs have Podman installed or allow you to run portable apps:

```bash
# On your build machine (Ubuntu 24.04), install Podman to build images:
sudo apt update
sudo apt install podman

# Verify installation
podman --version
```

The school PC will use the container images from your USB without needing Podman binaries on the USB.

#### Option B: Truly Portable (No Podman on School PC)

**For Windows school PCs without Podman:**

Unfortunately, Podman on Windows requires WSL2, which needs admin rights. However, you have alternatives:

1. **Ask IT to install Podman Desktop** (it's free and legitimate dev tool)
2. **Use the Git-based approach** instead (see GIT_SETUP.md) if school PCs allow installing software
3. **Use Docker Desktop** if it's already installed on school PCs (works the same way)

**Reality check:** Container technology requires some runtime. The `.tar` files on USB are just images - they need Podman/Docker to run them.

**Best approach for restricted PCs:**
- Store everything on USB (images, projects, configs)
- Use school PC's installed container runtime (if any)
- Or use Git-based setup and download images once per PC

### 4. Install VcXsrv (X11 for Windows GUI Support)

**VcXsrv is portable and goes ON YOUR USB, not on the school PC!**

VcXsrv is a Windows executable, so you can't extract it properly on Linux, but you **can** download it:

```bash
# Stay in your USB root directory
cd /run/media/$USER/DEVUSB   # or wherever your USB is mounted

# Download VcXsrv installer (Windows .exe file)
wget https://sourceforge.net/projects/vcxsrv/files/vcxsrv/1.20.14.0/vcxsrv-64.1.20.14.0.installer.exe/download -O vcxsrv/vcxsrv-installer.exe

# Note: The installer needs to be extracted on a Windows PC
```

**You'll need to extract it on Windows later:**

When you get to a Windows PC:
1. Run `vcxsrv/vcxsrv-installer.exe` from your USB
2. Install it temporarily to extract files
3. Copy `C:\Program Files\VcXsrv\*` back to `vcxsrv/` on USB
4. Delete the installer and uninstall VcXsrv from that PC

**Or use the helper script on Windows:**
```cmd
REM On any Windows PC, from your USB:
E:\download_vcxsrv.bat
```

**Alternative: Skip for now**
- You can build the container images on Linux now
- Add VcXsrv later when you're on a Windows PC
- Container images work on Linux without VcXsrv (uses native X11)

### 5. Install Neovim Portable with Kickstart

```bash
# Download Neovim portable
wget https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz
mkdir -p tools/nvim-portable
tar xzf nvim-linux64.tar.gz --strip-components=1 -C tools/nvim-portable/
rm nvim-linux64.tar.gz

# Clone Kickstart.nvim config (includes LSP, debugger, autocomplete)
git clone https://github.com/nvim-lua/kickstart.nvim.git config/nvim
```

### 6. Install Qt Designer Portable (Windows)

Qt Designer needs to be downloaded from a Windows build. Download the standalone designer:

```bash
# Create a placeholder - you'll need to download Qt Designer from Windows
mkdir -p tools/designer
echo "Download Qt Designer 6.8 standalone from https://www.qt.io/download-qt-installer" > tools/designer/README.txt
```

**On Windows:** Download Qt Designer standalone or extract from Qt installation:
- https://www.qt.io/download-qt-installer
- After installation, copy `designer.exe` and necessary DLLs to `tools/designer/`

### 7. Install Eclipse Portable (Optional, for Java GUI design)

```bash
# Download Eclipse Java Edition
wget https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/2024-09/R/eclipse-java-2024-09-R-linux-gtk-x86_64.tar.gz -O eclipse.tar.gz
mkdir -p tools/eclipse-portable
tar xzf eclipse.tar.gz --strip-components=1 -C tools/eclipse-portable/
rm eclipse.tar.gz
```

### 8. Build Container Images

**Python Container with PyQt6:**

```bash
# Create a build script
cat > build_python_image.sh <<'EOF'
#!/bin/bash
podman build -t python-gui -f - . <<DOCKERFILE
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-pyqt6 \
    pyqt6-dev-tools \
    git \
    curl \
    && pip3 install --break-system-packages debugpy black pyright \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ENV PYTHONUNBUFFERED=1
WORKDIR /workspace
CMD ["/bin/bash"]
DOCKERFILE
podman save python-gui -o images/python-gui.tar
EOF

chmod +x build_python_image.sh
./build_python_image.sh
```

**Java Container:**

```bash
# Create a build script
cat > build_java_image.sh <<'EOF'
#!/bin/bash
podman build -t java-gui -f - . <<DOCKERFILE
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    maven \
    gradle \
    git \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
WORKDIR /workspace
CMD ["/bin/bash"]
DOCKERFILE
podman save java-gui -o images/java-gui.tar
EOF

chmod +x build_java_image.sh
./build_java_image.sh
```

### 9. Create Startup Scripts

The `START_WINDOWS.bat` and `start_linux.sh` files should already exist in your repository root. If not, they are included in the project.

### 10. Add SSH Keys (Optional)

To use GitHub/GitLab without passwords:

```bash
mkdir -p config/.ssh
cp ~/.ssh/id_ed25519* config/.ssh/
# Make sure permissions are correct
chmod 700 config/.ssh
chmod 600 config/.ssh/id_ed25519
chmod 644 config/.ssh/id_ed25519.pub
```

### 11. Test the Setup

**On Linux:**
```bash
./start_linux.sh
# Choose Python or Java
# You should see a bash prompt inside the container
```

**On Windows:**
- Double-click `START_WINDOWS.bat`
- Choose Python or Java
- VcXsrv should start in the system tray
- You should get a bash prompt

### 12. Create Sample Projects

```bash
# Python sample
mkdir -p projects/python/hello_pyqt
cat > projects/python/hello_pyqt/main.py <<'EOF'
from PyQt6.QtWidgets import QApplication, QMainWindow, QLabel
import sys

app = QApplication(sys.argv)
window = QMainWindow()
window.setWindowTitle("Hello PyQt6")
label = QLabel("Hello from Portable USB!", window)
label.setGeometry(50, 50, 300, 50)
window.setGeometry(100, 100, 400, 200)
window.show()
sys.exit(app.exec())
EOF

# Java sample
mkdir -p projects/java/HelloSwing
cat > projects/java/HelloSwing/Main.java <<'EOF'
import javax.swing.*;

public class Main {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            JFrame frame = new JFrame("Hello Swing");
            frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            frame.add(new JLabel("Hello from Portable USB!", SwingConstants.CENTER));
            frame.setSize(400, 200);
            frame.setVisible(true);
        });
    }
}
EOF
```

## Verification Checklist

- [ ] USB formatted as exFAT
- [ ] All folders created
- [ ] Podman binaries present
- [ ] VcXsrv files present
- [ ] Neovim portable works
- [ ] Python container image created (~1.8 GB)
- [ ] Java container image created (~1.6 GB)
- [ ] Scripts are executable (`chmod +x start_linux.sh`)
- [ ] Sample projects created
- [ ] Total size < 4.5 GB

## Troubleshooting

### USB won't mount on Windows
- Make sure it's formatted as exFAT (not ext4 or other Linux formats)
- Windows natively supports exFAT without drivers

### Podman won't start on Windows
- Make sure WSL 2 is enabled (Podman for Windows requires it)
- If blocked, use the git-based setup instead (see GIT_SETUP.md)

### Container images too large
- Images are compressed as `.tar` files
- Python image: ~1.8 GB
- Java image: ~1.6 GB
- This is normal for full development environments

### Neovim plugins not loading
- First run takes longer (downloads plugins)
- Inside container: `export NVIM_APPNAME=../config/nvim && nvim .`
- Let it finish installing on first run

### GUI apps won't display on Windows
- Make sure VcXsrv is running (check system tray)
- Try restarting VcXsrv: `taskkill /IM vcxsrv.exe /F` then run `START_WINDOWS.bat` again

## Maintenance

### Updating Containers

```bash
# Rebuild Python container
./build_python_image.sh

# Rebuild Java container
./build_java_image.sh
```

### Updating Neovim Config

```bash
cd config/nvim
git pull
```

### Adding More Tools

Just extract portable versions to the `tools/` folder and update your startup scripts.

## Total Build Time

- Format USB: 2 minutes
- Download Podman/VcXsrv: 3 minutes
- Download Neovim: 1 minute
- Build Python container: 5 minutes
- Build Java container: 5 minutes
- Setup scripts & samples: 2 minutes

**Total: ~18-20 minutes** (depending on internet speed)

---

**Next Steps:** See `QUICKSTART.md` for daily usage instructions.
