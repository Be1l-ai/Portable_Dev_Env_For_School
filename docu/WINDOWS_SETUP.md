# Windows Tools Setup Guide

**Run these scripts on a Windows PC to add Windows-only tools to your USB.**

## Quick Start

### All-in-One Script (Recommended)
```cmd
REM Plug in your USB, then run:
E:\setup_windows_tools.bat
```

This script will help you add all Windows tools to your USB:
- VcXsrv (required for GUI)
- Qt Designer (optional, for visual PyQt6 design)
- Eclipse (optional, for visual Java Swing design)

---

## Individual Setup Scripts

If you prefer to set up tools one at a time:

### 1. VcXsrv (Required for GUI)
```cmd
E:\download_vcxsrv.bat
```

**What it does:**
- Downloads/installs VcXsrv
- Copies portable version to USB
- Tests that it works

**Required:** Yes (GUI apps won't display without it)

---

### 2. Qt Designer (Optional)
**Included in:** `setup_windows_tools.bat`

**Manual steps:**
1. Download Qt from: https://www.qt.io/download-qt-installer
2. Install Qt (choose MinGW version)
3. Copy files:
   ```cmd
   xcopy "C:\Qt\6.8.0\mingw_64\bin\designer.exe" E:\tools\designer\
   xcopy "C:\Qt\6.8.0\mingw_64\bin\Qt6*.dll" E:\tools\designer\
   ```

**Required:** No (you can code PyQt6 manually)

---

### 3. Eclipse (Optional)
**Included in:** `setup_windows_tools.bat`

**Manual steps:**
1. Download Eclipse IDE for Java from: https://www.eclipse.org/downloads/
2. Extract to: `E:\tools\eclipse-portable\`
3. You should have: `E:\tools\eclipse-portable\eclipse.exe`

**Required:** No (you can code Java Swing manually)

---

## Verification

After setup, your USB should have:

```
E:\
├── vcxsrv\
│   └── vcxsrv.exe           ✓ Required
├── tools\
│   ├── designer\
│   │   └── designer.exe     ⚠ Optional
│   └── eclipse-portable\
│       └── eclipse.exe      ⚠ Optional
├── images\
│   ├── python-gui.tar       ✓ Build on Linux
│   └── java-gui.tar         ✓ Build on Linux
└── START_WINDOWS.bat
```

Test by running:
```cmd
E:\START_WINDOWS.bat
```

---

## Troubleshooting

### VcXsrv won't copy
- Make sure VcXsrv is installed in `C:\Program Files\VcXsrv\`
- Run the script as Administrator if needed

### Qt Designer missing DLLs
- Copy all `.dll` files from Qt's `bin` folder
- Test Designer: `E:\tools\designer\designer.exe`
- If it complains about missing DLLs, copy more from Qt

### Eclipse won't start
- Make sure you downloaded the ZIP version (not installer)
- Eclipse needs Java installed on the PC
- Or use the embedded JRE version

---

## What Gets Added vs What's Already There

### Added on Linux (already done):
- ✅ Container images (`python-gui.tar`, `java-gui.tar`)
- ✅ Neovim portable (Linux binary)
- ✅ Scripts (`START_WINDOWS.bat`, etc.)

### Added on Windows (these scripts):
- 📦 VcXsrv (Windows X11 server)
- 📦 Qt Designer (Windows GUI designer)
- 📦 Eclipse (Windows/Java GUI designer)

---

## Next Steps

After running these scripts:

1. **Test on same Windows PC:**
   ```cmd
   E:\START_WINDOWS.bat
   ```

2. **On school PC (PC 19):**
   ```cmd
   E:\setup_school_pc.bat     REM One-time setup
   E:\START_WINDOWS.bat       REM Daily use
   ```

See `QUICKSTART.md` for daily usage instructions.
