# Git-Based Setup Guide

**Use this setup when you prefer Git over USB, or can't use USB sticks on school lab computers.**

## What Is This?

Instead of carrying a USB stick, you'll:
1. **Clone this repo** to any Windows/Linux computer (school PC, your laptop, etc.)
2. **Download container images** from GitHub Releases (~2.2 GB, one time)
3. **Run `auto-setup.bat`** (Windows) or **`auto-setup.sh`** (Linux) - everything else is automatic

## Why Git Instead of USB?

✅ **No USB needed** - Works on USB-blocked lab PCs  
✅ **Sync your code** - Push/pull project changes via Git  
✅ **Easy updates** - `git pull` to get latest fixes  
✅ **Works anywhere** - Clone on any computer with internet  
✅ **Team friendly** - Share same environment with classmates  

❌ **Requires disk space** - ~2.5 GB on the computer  
❌ **Initial download** - ~2.4 GB (4-5 minutes on fast connection)  
❌ **Internet needed** - For first-time setup only

---

## Quick Start (Windows School PC)

**First Time Setup (~10 minutes):**

```cmd
REM 1. Open Command Prompt (no admin needed)
cd C:\Users\%USERNAME%\Documents

REM 2. Clone the repository
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
cd Portable_Dev_Env_For_School

REM 3. Run auto-setup (handles everything automatically)
auto-setup.bat
```

**What `auto-setup.bat` does:**
1. ✅ Checks if Docker/Podman installed (offers to install WSL2+Docker if missing)
2. ✅ Downloads container images from GitHub Releases (~2.2 GB)
3. ✅ Loads images into Docker/Podman
4. ✅ Launches `START_WINDOWS.bat` - you're ready to code!

**Daily Usage (15 seconds):**

```cmd
cd C:\Users\%USERNAME%\Documents\Portable_Dev_Env_For_School
git pull
START_WINDOWS.bat
```

**When Done:**

```cmd
REM Save your work
git add projects\
git commit -m "Completed assignment"
git push

REM Optional: Delete everything (leaves no trace)
cd ..
rmdir /s /q Portable_Dev_Env_For_School
```

---

## Quick Start (Linux)

**First Time Setup (~10 minutes):**

```bash
# 1. Clone the repository
cd ~/
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
cd Portable_Dev_Env_For_School

# 2. Make scripts executable
chmod +x auto-setup.sh start_linux.sh

# 3. Run auto-setup (handles everything automatically)
./auto-setup.sh
```

**What `auto-setup.sh` does:**
1. ✅ Checks for Podman/Docker (prompts to install if missing)
2. ✅ Downloads container images from GitHub Releases (~2.2 GB)
3. ✅ Loads images into Podman/Docker
4. ✅ Launches `start_linux.sh` - you're ready to code!

**Daily Usage:**

```bash
cd ~/Portable_Dev_Env_For_School
git pull
./start_linux.sh
```

---

## What Gets Downloaded?

| Component | Size | What It Contains |
|-----------|------|------------------|
| **Git repo** | ~165 KB | Scripts, configs, documentation |
| **python-gui.tar** | 1.1 GB | Python 3.12.3 + PyQt6 + 447 packages |
| **java-gui.tar** | 1.1 GB | JDK 21 + Maven + Gradle + 456 packages |
| **Total** | **2.2 GB** | Complete development environment |

**Download time:** ~4-5 minutes on 10 Mbps connection

---

## Common Scenarios

### Scenario 1: First Time on School PC

```cmd
REM 10 minute setup
cd C:\Users\%USERNAME%\Documents
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
cd Portable_Dev_Env_For_School
auto-setup.bat
REM Everything installs automatically, then launches
```

### Scenario 2: Daily Use (Already Set Up)

```cmd
REM 15 seconds to start
cd C:\Users\%USERNAME%\Documents\Portable_Dev_Env_For_School
git pull
START_WINDOWS.bat
```

### Scenario 3: Work Session + Save Changes

```cmd
REM Work on your project
START_WINDOWS.bat
REM ... code in Python or Java ...
REM Exit container (type 'exit' or Ctrl+D)

REM Save your work to Git
git add projects\
git commit -m "Finished lab assignment"
git push
```

### Scenario 4: Leave No Trace (Clean Up)

```cmd
REM After pushing your code
cd C:\Users\%USERNAME%\Documents
rmdir /s /q Portable_Dev_Env_For_School
REM All files deleted - computer is clean
```

### Scenario 5: Team Project

```bash
# Everyone clones the same repo
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git

# Everyone runs auto-setup (downloads same images)
./auto-setup.sh  # Linux
# or
auto-setup.bat   # Windows

# Everyone works on projects/ folder
# Push/pull to collaborate
git add projects/team_project/
git commit -m "Added my part"
git push
```

---

## Troubleshooting

### Issue: `git clone` blocked by school firewall

**Solution:** Use HTTPS instead of SSH
```cmd
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
```

### Issue: School PC deletes `C:\Users\%USERNAME%\Documents` on logout

**Solution:** Use cloud-synced folder
```cmd
cd "%USERPROFILE%\OneDrive"
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
```

Or use a different persistent location:
```cmd
cd D:\
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
```

### Issue: Can't download from GitHub Releases (firewall blocks)

**Solution 1:** Use browser to download, then move files
```cmd
REM Download python-gui.tar and java-gui.tar with browser
move %USERPROFILE%\Downloads\python-gui.tar images\
move %USERPROFILE%\Downloads\java-gui.tar images\
```

**Solution 2:** Use alternative hosting (Google Drive, Dropbox)
- Update `scripts/build/download_images.bat` with new URLs
- Commit and push changes

### Issue: WSL2/Docker won't install (admin blocked)

**Solution:** Use a different school PC that allows WSL2, or switch to USB setup

### Issue: Images won't load (`docker load` fails)

**Check image files:**
```cmd
dir images
REM python-gui.tar should be ~1.1 GB
REM java-gui.tar should be ~1.1 GB
```

**Re-download if corrupted:**
```cmd
del images\python-gui.tar
del images\java-gui.tar
scripts\build\download_images.bat
```

---

## USB vs Git Comparison

| Feature | USB Setup | Git Setup |
|---------|-----------|-----------|
| **Setup time** | 20 min (first build) | 10 min (downloads) |
| **Storage needed** | 8 GB USB stick | 2.5 GB disk space |
| **Portability** | Physical USB stick | Clone anywhere |
| **Internet needed** | No (after setup) | Yes (first time only) |
| **Update method** | Rebuild USB | `git pull` |
| **Code backup** | Manual copy | Automatic (`git push`) |
| **Team sharing** | Pass USB around | Everyone clones repo |
| **Cost** | ~$10 USB | Free |
| **Works offline** | Yes | Yes (after setup) |
| **USB-blocked PCs** | ❌ No | ✅ Yes |

**Recommendation:**
- **USB Setup**: If you use the same PC daily, or school blocks WSL2
- **Git Setup**: If you move between PCs, or want automatic backups
