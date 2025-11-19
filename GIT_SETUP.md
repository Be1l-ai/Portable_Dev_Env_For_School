# Git-Based Setup Guide - No USB Required

**Use this setup when you can't use a USB stick or prefer working from Git on school lab computers.**

## Overview

Instead of carrying a USB stick, you'll:
1. Clone this repo to any Windows/Linux computer (school PC, cloud VM, etc.)
2. Download the large container images separately (once)
3. Run everything locally without admin rights

## Advantages vs USB Setup

- ✅ No need to buy/carry a USB stick
- ✅ Works on any computer with internet access (initial setup)
- ✅ Can sync your code changes via Git
- ✅ Easier to update (just `git pull`)
- ✅ Works on locked-down lab PCs with no USB ports allowed

## Disadvantages

- ❌ Requires ~4.3 GB of disk space on the computer
- ❌ First-time setup downloads ~4.2 GB (10-15 minutes)
- ❌ Need to clean up when done (or leave it if you have space)
- ❌ Container images need to be hosted separately (Git won't store 3.5 GB files)

---

## Setup Instructions

### Part 1: Prepare Your Repository (One-Time Setup)

**Do this on your home Linux machine or any machine where you've already built the USB setup:**

```bash
# 1. Navigate to your portable dev environment folder
cd /path/to/your/dev/environment

# 2. Initialize Git repo if not already done
git init
git checkout -b main

# 3. The .gitignore file is already created - it excludes:
#    - images/*.tar (container images)
#    - podman/ (binaries)
#    - vcxsrv/ (binaries)
#    - tools/nvim-portable/ (binaries)
#    - tools/designer/ (Qt Designer binaries)
#    - tools/eclipse-portable/ (Eclipse binaries)

# 4. Add and commit the lightweight files
git add .
git commit -m "Initial portable dev environment setup"

# 5. Create a GitHub/GitLab repository (use private if you want)
# On GitHub: Create new repo named "Portable_Dev_Env_For_School"
# Then push:
git remote add origin https://github.com/YOUR_USERNAME/Portable_Dev_Env_For_School.git
git push -u origin main
```

### Part 2: Host Container Images Separately

The container images (~3.5 GB total) can't be stored in Git. You have three options:

#### Option A: GitHub Releases (Recommended)

```bash
# 1. Create a release on GitHub
# 2. Upload python-gui.tar and java-gui.tar as release assets

# Or use the GitHub CLI:
gh release create v1.0 \
  images/python-gui.tar \
  images/java-gui.tar \
  --repo Be1l-ai/Portable_Dev_Env_For_School \
  --title "Container Images v1.0" \
  --notes "Python and Java container images for portable dev environment"
```

#### Option B: Cloud Storage (Easy)

Upload the files to:
- Google Drive (get shareable link)
- Dropbox
- OneDrive
- Mega.nz
- Any file hosting service

#### Option C: Git LFS (If Your Host Supports It)

```bash
# Install Git LFS
git lfs install

# Track the large files
git lfs track "images/*.tar"
git add .gitattributes
git add images/*.tar
git commit -m "Add container images with LFS"
git push
```

---

### Part 3: Using on School Lab PCs (Windows)

**First Time Setup (10-15 minutes):**

```cmd
REM 1. Open Command Prompt (no admin needed)
cd C:\Temp

REM 2. Clone the repository
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git dev
cd dev

REM 3. Download the container images
REM If using GitHub Releases:
curl -L -o images\python-gui.tar https://github.com/Be1l-ai/Portable_Dev_Env_For_School/releases/download/v1.0/python-gui.tar
curl -L -o images\java-gui.tar https://github.com/Be1l-ai/Portable_Dev_Env_For_School/releases/download/v1.0/java-gui.tar

REM If using Google Drive/Dropbox, download manually with browser and move to images\ folder

REM 4. Download and extract portable tools
REM Download Podman for Windows
curl -L -o podman.zip https://github.com/containers/podman/releases/download/v5.3.0/podman-remote-release-windows_amd64.zip
tar -xf podman.zip -C podman
del podman.zip

REM Download VcXsrv (X11 server)
REM Visit: https://sourceforge.net/projects/vcxsrv/files/latest/download
REM Extract to vcxsrv\ folder

REM 5. Start the environment
START_WINDOWS.bat
```

**Daily Usage (15 seconds):**

```cmd
cd C:\Temp\dev
git pull
START_WINDOWS.bat
```

**When Done:**

```cmd
REM Commit your work
git add projects\
git commit -m "Updated project"
git push

REM Optional: Delete everything (leaves no trace)
cd C:\
rmdir /s /q C:\Temp\dev
```

---

### Part 4: Using on Your Linux Machine

**First Time Setup:**

```bash
# 1. Clone the repository
cd ~/
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git dev
cd dev

# 2. Download container images
# If using GitHub Releases:
wget https://github.com/Be1l-ai/Portable_Dev_Env_For_School/releases/download/v1.0/python-gui.tar -O images/python-gui.tar
wget https://github.com/Be1l-ai/Portable_Dev_Env_For_School/releases/download/v1.0/java-gui.tar -O images/java-gui.tar

# 3. Install Podman if not already installed
sudo apt install podman  # Ubuntu/Debian
# or
sudo dnf install podman  # Fedora

# 4. Load the container images
podman load -i images/python-gui.tar
podman load -i images/java-gui.tar

# 5. Make scripts executable
chmod +x start_linux.sh

# 6. Start the environment
./start_linux.sh
```

**Daily Usage:**

```bash
cd ~/dev
git pull
./start_linux.sh
```

---

## Helper Scripts

### Download Script for Container Images

Create a `download_images.sh` script in the repo root:

```bash
#!/bin/bash
# Download container images from GitHub Releases

REPO="Be1l-ai/Portable_Dev_Env_For_School"
VERSION="v1.0"

echo "Downloading container images..."

wget https://github.com/$REPO/releases/download/$VERSION/python-gui.tar -O images/python-gui.tar
wget https://github.com/$REPO/releases/download/$VERSION/java-gui.tar -O images/java-gui.tar

echo "Loading images into Podman..."
podman load -i images/python-gui.tar
podman load -i images/java-gui.tar

echo "Done! Run ./start_linux.sh to start."
```

### Windows Batch Download Script

Create a `download_images.bat` script:

```batch
@echo off
REM Download container images from GitHub Releases

set REPO=Be1l-ai/Portable_Dev_Env_For_School
set VERSION=v1.0

echo Downloading container images...

curl -L -o images\python-gui.tar https://github.com/%REPO%/releases/download/%VERSION%/python-gui.tar
curl -L -o images\java-gui.tar https://github.com/%REPO%/releases/download/%VERSION%/java-gui.tar

echo Done! Run START_WINDOWS.bat to start.
pause
```

---

## Repository Size

After excluding large binaries via `.gitignore`:

| Component | Size |
|-----------|------|
| Scripts (START_WINDOWS.bat, start_linux.sh) | ~5 KB |
| Config files (Neovim config) | ~50 KB |
| Documentation (*.md files) | ~100 KB |
| Sample projects | ~10 KB |
| **Total Git repo size** | **~165 KB** |

The large files (container images, binaries) are downloaded separately:

| Component | Size | Download Time (10 Mbps) |
|-----------|------|-------------------------|
| python-gui.tar | ~1.8 GB | ~3 minutes |
| java-gui.tar | ~1.6 GB | ~2.5 minutes |
| Podman Windows | ~150 MB | ~20 seconds |
| VcXsrv | ~40 MB | ~5 seconds |
| **Total download** | **~3.6 GB** | **~6 minutes** |

---

## Workflow on School Lab PCs

### Scenario 1: Quick Edit Session (30 minutes)

```cmd
REM Assuming you've already set it up once
cd C:\Temp\dev
git pull
START_WINDOWS.bat
REM ... work on your code ...
REM Exit container (Ctrl+D)
git add projects\
git commit -m "Added feature X"
git push
```

### Scenario 2: Fresh Lab PC (First Time)

```cmd
REM 10-15 minute setup
cd C:\Temp
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git dev
cd dev
download_images.bat
START_WINDOWS.bat
```

### Scenario 3: Leave No Trace

```cmd
REM After you're done:
git push
cd C:\
rmdir /s /q C:\Temp\dev
REM All traces removed - fresh PC again
```

---

## Troubleshooting

### Can't clone repo (blocked by firewall)

Use HTTPS instead of SSH:
```bash
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
```

### Can't download container images (school blocks GitHub Releases)

Upload to Google Drive/Dropbox and download via browser, then:
```cmd
move Downloads\python-gui.tar C:\Temp\dev\images\
move Downloads\java-gui.tar C:\Temp\dev\images\
```

### School PC deletes C:\Temp on logout

Use a different folder:
```cmd
cd %USERPROFILE%\Documents
git clone https://github.com/YOUR_USERNAME/Portable_Dev_Env_For_School.git dev
```

Or use a cloud-synced folder:
```cmd
cd "%USERPROFILE%\OneDrive\dev"
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
```

### Podman won't work (WSL 2 blocked)

You'll need to use the USB setup instead, or use a different lab PC that allows WSL 2.

---

## Advantages for Team Projects

If you're working with classmates:

1. **Everyone clones the same repo** - same environment, no "works on my machine" issues
2. **Share container images once** - host on Google Drive, everyone downloads
3. **Collaborate via Git** - everyone pushes their project code
4. **Consistent tools** - same Neovim config, same Python/Java versions

---

## Comparison: USB vs Git Setup

| Feature | USB Setup | Git Setup |
|---------|-----------|-----------|
| Initial setup time | 20 min | 15 min |
| Storage required | 8 GB USB stick | 4.3 GB on PC |
| Portability | Carry USB everywhere | Clone anywhere |
| Works offline | Yes (after first setup) | Yes (after first setup) |
| Easy to update | Rebuild USB | `git pull` |
| Requires internet | Only for building | Only for cloning |
| Cost | ~$10 for USB | Free |
| Works on USB-blocked PCs | No | Yes |

---

**Next Steps:** See `QUICKSTART.md` for daily usage instructions.
