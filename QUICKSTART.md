# Quick Start Guide - Portable Dev Environment

**Daily usage instructions for your portable Python + Java GUI development environment.**

## Overview

This environment gives you:
- **Python 3.12** with PyQt6 for GUI development
- **Java 21** with Swing for GUI development
- **Neovim** with LSP, debugger, and autocomplete
- **Qt Designer** for visual PyQt6 UI design
- **Eclipse** with WindowBuilder for visual Swing UI design
- **Git** for version control

Everything runs in containers with full GUI support - no admin rights needed!

---

## Daily Workflow

### On Windows (School Lab PC)

**Quick Start (15 seconds):**

```cmd
REM 1. Insert USB or navigate to your cloned folder
E:
cd E:\

REM 2. Start the environment
START_WINDOWS.bat

REM 3. Choose Python (p) or Java (j)
```

**What happens:**
1. VcXsrv starts (X11 server - appears in system tray)
2. Podman machine starts (takes ~5 seconds)
3. You get a bash prompt inside your chosen container
4. All GUI apps will open as native Windows windows

### On Linux (Your Home Machine)

**Quick Start (5 seconds):**

```bash
# 1. Navigate to your dev environment
cd /path/to/dev/environment

# 2. Start the environment
./start_linux.sh

# 3. Choose Python (p) or Java (j)
```

---

## Inside the Container

Once you're inside the container (you'll see a bash prompt), here's what you can do:

### Basic Navigation

```bash
# You start in /workspace, which is mapped to:
# - USB: /projects/python or /projects/java
# - Git: C:\Temp\dev\projects\python or C:\Temp\dev\projects\java

# List files
ls -la

# Navigate to a project
cd my_project/

# Start Neovim
nvim .
```

### Python Development

```bash
# Run a Python script
python3 main.py

# Run with GUI (opens window on your actual screen)
python3 gui_app.py

# Install packages (already has PyQt6)
pip3 install --break-system-packages some-package

# Open Qt Designer
designer my_ui.ui &

# Run tests
pytest tests/

# Format code
black *.py
```

### Java Development

```bash
# Compile Java code
javac Main.java

# Run Java application (GUI opens on your actual screen)
java Main

# Use Maven
mvn clean install
mvn exec:java

# Use Gradle
gradle build
gradle run

# Open Eclipse (for WindowBuilder GUI design)
# Exit container first (Ctrl+D), then on Windows:
E:\tools\eclipse-portable\eclipse.exe
```

---

## Using Neovim

### First Time Setup

```bash
# Inside container, start Neovim
nvim .

# First run will install plugins (takes 1-2 minutes)
# Wait for it to finish, then restart Neovim:
# Press: Esc, then :q, then Enter
nvim .
```

### Essential Neovim Shortcuts

| Key | Action |
|-----|--------|
| `Ctrl+P` | Fuzzy find files |
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<leader>ff` | Find files (telescope) |
| `<leader>fg` | Live grep |
| `<leader>fb` | Browse buffers |
| `F5` | Start debugger |
| `:LspInfo` | Show LSP status |
| `:Mason` | Manage LSP servers |

*Note: `<leader>` is Space by default in Kickstart.nvim*

### Python-Specific

```vim
" In Neovim (command mode):
:LspInfo        " Should show 'pyright' attached
:Mason          " Install additional tools

" Format current file
:!black %

" Run current file
:!python3 %
```

### Java-Specific

```vim
" In Neovim (command mode):
:LspInfo        " Should show 'jdtls' attached

" Format current file
:!google-java-format -i %

" Compile and run
:!javac % && java $(basename % .java)
```

---

## GUI Development Workflows

### Python + PyQt6 Workflow

**Option 1: Code Everything (Neovim)**

```bash
# 1. Create new project
mkdir hello_pyqt && cd hello_pyqt

# 2. Create main.py
nvim main.py
```

```python
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
```

```bash
# 3. Run
python3 main.py
```

**Option 2: Visual Design (Qt Designer)**

```bash
# 1. Open Qt Designer
designer &

# 2. Design your UI visually
# Save as: my_ui.ui

# 3. Load UI in Python
nvim main.py
```

```python
from PyQt6 import uic
from PyQt6.QtWidgets import QApplication
import sys

Form, Window = uic.loadUiType("my_ui.ui")
app = QApplication(sys.argv)
window = Window()
form = Form()
form.setupUi(window)
window.show()
sys.exit(app.exec())
```

### Java + Swing Workflow

**Option 1: Code Everything (Neovim)**

```bash
# 1. Create new project
mkdir HelloSwing && cd HelloSwing

# 2. Create Main.java
nvim Main.java
```

```java
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
```

```bash
# 3. Compile and run
javac Main.java
java Main
```

**Option 2: Visual Design (Eclipse + WindowBuilder)**

On Windows (must exit container first):

```cmd
REM 1. Exit container (Ctrl+D)

REM 2. Open Eclipse
E:\tools\eclipse-portable\eclipse.exe

REM 3. Import your Java project from E:\projects\java\

REM 4. Right-click Java file → Open With → WindowBuilder Editor

REM 5. Design GUI visually, code is auto-generated
```

---

## Git Workflow

### Working with GitHub/GitLab

```bash
# Inside container

# Clone a repo
git clone https://github.com/yourusername/your-repo.git
cd your-repo

# Make changes
nvim some_file.py

# Commit and push
git add .
git commit -m "Added new feature"
git push
```

### SSH Keys (Optional Setup)

If you want to push without entering passwords:

```bash
# Copy your SSH key to config/.ssh/
# On your home machine:
cp ~/.ssh/id_ed25519* /path/to/usb/config/.ssh/

# In container, use the key:
eval $(ssh-agent)
ssh-add /workspace/../config/.ssh/id_ed25519
```

---

## Common Tasks

### Install Python Packages

```bash
# Inside container
pip3 install --break-system-packages package-name

# For a specific project (recommended)
python3 -m venv venv
source venv/bin/activate
pip install package-name
```

### Add Java Dependencies (Maven)

Edit `pom.xml`:

```xml
<dependencies>
    <dependency>
        <groupId>group.id</groupId>
        <artifactId>artifact-id</artifactId>
        <version>1.0.0</version>
    </dependency>
</dependencies>
```

```bash
mvn clean install
```

### Update Container Images

```bash
# Exit container and stop environment

# On Linux, rebuild:
./build_images.sh all

# Or download latest:
./download_images.sh YOUR_USERNAME/Portable_Dev_Env_For_School v2.0
```

---

## Troubleshooting

### GUI windows not appearing (Windows)

```cmd
REM Check if VcXsrv is running
tasklist | find "vcxsrv"

REM If not, restart it
START_WINDOWS.bat
```

### Container won't start

```bash
# Check Podman status
podman ps -a

# Remove old containers
podman rm -f python-dev java-dev

# Restart from scratch
START_WINDOWS.bat  # or ./start_linux.sh
```

### Neovim LSP not working

```vim
" Inside Neovim
:LspInfo          " Check if LSP is attached
:Mason            " Install missing servers
:checkhealth      " Diagnose issues
```

### Can't push to Git (authentication failed)

```bash
# Use HTTPS with token
git remote set-url origin https://TOKEN@github.com/user/repo.git

# Or setup SSH keys (see Git Workflow section above)
```

### Container is slow

```bash
# Stop container
exit  # or Ctrl+D

# Remove unused images/containers
podman system prune -a

# Restart
START_WINDOWS.bat  # or ./start_linux.sh
```

---

## Keyboard Shortcuts Reference

### Windows (Outside Container)

| Shortcut | Action |
|----------|--------|
| Double-click `START_WINDOWS.bat` | Start environment |
| `Ctrl+C` in terminal | Stop container |
| `Ctrl+D` | Exit container |

### Inside Container (Bash)

| Shortcut | Action |
|----------|--------|
| `Ctrl+D` | Exit container |
| `Ctrl+C` | Cancel current command |
| `Ctrl+L` | Clear screen |
| `Ctrl+R` | Search command history |

### Neovim (Normal Mode)

| Shortcut | Action |
|----------|--------|
| `Esc` | Enter normal mode |
| `:w` | Save file |
| `:q` | Quit |
| `:wq` | Save and quit |
| `i` | Enter insert mode |
| `v` | Visual selection mode |
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste |
| `u` | Undo |
| `Ctrl+R` | Redo |

---

## Example Projects

### Python: Simple PyQt6 Calculator

```python
from PyQt6.QtWidgets import QApplication, QWidget, QVBoxLayout, QLineEdit, QPushButton
import sys

class Calculator(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Calculator")
        layout = QVBoxLayout()
        self.display = QLineEdit()
        layout.addWidget(self.display)
        
        for num in range(10):
            btn = QPushButton(str(num))
            btn.clicked.connect(lambda checked, n=num: self.display.setText(self.display.text() + str(n)))
            layout.addWidget(btn)
        
        self.setLayout(layout)

app = QApplication(sys.argv)
calc = Calculator()
calc.show()
sys.exit(app.exec())
```

### Java: Simple Swing Counter

```java
import javax.swing.*;
import java.awt.*;

public class Counter extends JFrame {
    private int count = 0;
    private JLabel label = new JLabel("Count: 0", SwingConstants.CENTER);
    
    public Counter() {
        setTitle("Counter");
        setSize(300, 200);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLayout(new BorderLayout());
        
        label.setFont(new Font("Arial", Font.BOLD, 24));
        add(label, BorderLayout.CENTER);
        
        JButton btn = new JButton("Click Me!");
        btn.addActionListener(e -> {
            count++;
            label.setText("Count: " + count);
        });
        add(btn, BorderLayout.SOUTH);
        
        setVisible(true);
    }
    
    public static void main(String[] args) {
        SwingUtilities.invokeLater(Counter::new);
    }
}
```

---

## Tips & Best Practices

### Project Organization

```
projects/
├── python/
│   ├── calculator/
│   ├── todo_app/
│   └── game/
└── java/
    ├── StudentManager/
    ├── LibrarySystem/
    └── Calculator/
```

### Git Ignore Recommendations

Add to each project's `.gitignore`:

```
# Python
__pycache__/
*.pyc
.venv/
venv/

# Java
*.class
target/
build/
.gradle/

# IDE
.idea/
.vscode/
*.swp
```

### Performance Tips

1. **Keep containers running** - Don't exit/restart unnecessarily
2. **Use .gitignore** - Don't commit large files
3. **Clean up regularly** - `podman system prune` removes old images
4. **Close unused GUI apps** - Free up memory

### Security Tips

1. **Don't commit SSH keys** - They're in `.gitignore` for a reason
2. **Use SSH keys instead of passwords** - Faster and more secure
3. **Lock your screen** - When stepping away from lab PC
4. **Delete local repo when done** - On shared PCs: `rmdir /s /q C:\Temp\dev`

---

## Getting Help

### Check Logs

```bash
# Podman logs
podman logs python-dev
podman logs java-dev

# Container status
podman ps -a
```

### Useful Commands

```bash
# Check Python version
python3 --version

# Check Java version
java --version

# Check Git version
git --version

# Check available packages (Python)
pip3 list

# Check Maven version
mvn --version
```

### Resources

- **Neovim help**: `:help` inside Neovim
- **PyQt6 docs**: https://www.riverbankcomputing.com/static/Docs/PyQt6/
- **Java Swing tutorial**: https://docs.oracle.com/javase/tutorial/uiswing/
- **Qt Designer guide**: https://doc.qt.io/qt-6/qtdesigner-manual.html

---

## Next Session Checklist

- [ ] Pull latest changes: `git pull`
- [ ] Check for container updates
- [ ] Backup important work: `git push`
- [ ] Clean up: `podman system prune` (if space is low)
- [ ] Update TODO list in projects

---

**Happy Coding! 🚀**

For setup instructions, see `USB_SETUP.md` or `GIT_SETUP.md`.
