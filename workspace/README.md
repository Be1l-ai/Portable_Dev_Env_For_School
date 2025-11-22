# Workspace Management Scripts

This folder contains scripts to transform the setup repository into your personal project workspace.

## Overview

After running the initial setup (downloading images, installing tools), you can **convert this repository into your own workspace** by:
1. Removing all setup files
2. Keeping only what you need to code (images, projects, tools)
3. Connecting to your own Git repository
4. Safely deleting everything when you're done

---

## The Workflow

### Step 1: Initial Setup

Clone and set up the environment:

```bash
# Clone the setup repository
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
cd Portable_Dev_Env_For_School

# Run auto-setup (downloads images, loads into Docker/Podman)
./auto-setup.sh          # Linux
# or
auto-setup.bat           # Windows

# Set up VS Code Dev Containers
./scripts/containers/setup_devcontainer.sh all
```

### Step 2: Clean Up Setup Files

Remove setup scripts and convert to workspace:

```bash
# Linux
./scripts/workspace/cleanup.sh

# Windows
scripts\workspace\cleanup.bat
```

**What `cleanup` does:**
- ✅ Removes git remote (disconnects from Be1l-ai/Portable_Dev_Env_For_School)
- ✅ Deletes setup scripts: `auto-setup.*`, `START_*`, `scripts/`, `docu/`
- ✅ Keeps only: `images/`, `projects/`, `tools/`
- ✅ Creates new `.gitignore` for workspace mode
- ✅ Prompts to connect to YOUR project repository

**Before cleanup:**
```
Portable_Dev_Env_For_School/
├── auto-setup.bat          ← Setup scripts
├── START_WINDOWS.bat       ← Launchers
├── scripts/                ← Build/setup scripts
├── docu/                   ← Documentation
├── images/                 ← Container images
├── projects/               ← Your code
└── tools/                  ← GUI tools
```

**After cleanup:**
```
MyProjectWorkspace/  (you can rename the folder)
├── images/          ← Container images (1.1 GB each)
├── projects/        ← Your code
├── tools/           ← GUI tools (optional)
└── .gitignore       ← New gitignore for workspace
```

### Step 3: Code Your Projects

Work on your projects using VS Code Dev Containers:

```bash
cd projects/python
code .

# VS Code prompts: "Reopen in Container"
# Now you can code with full Python/PyQt6 support!
```

Commit your changes:

```bash
git add .
git commit -m "Completed feature X"
git push
```

### Step 4: Bailout (Safe Deletion)

When you're done and want to delete the workspace:

```bash
# Linux
./scripts/workspace/bailout.sh

# Windows
scripts\workspace\bailout.bat
```

**What `bailout` does:**

**Safety Checks (all must pass):**
1. ✅ **Remote configured?** - Can't delete without backup
2. ✅ **No uncommitted files?** - All changes must be committed
3. ✅ **Everything pushed?** - All commits must be on remote

**If all checks pass:**
- Confirms deletion (type `DELETE` to proceed)
- 3-second countdown
- Deletes entire workspace directory
- Your code remains safe on your remote repository

**If any check fails:**
- Shows what's blocking deletion
- Provides commands to fix the issue
- Exits without deleting

---

## Script Details

### cleanup.sh / cleanup.bat

**Purpose:** Convert setup repo into your workspace

**Usage:**
```bash
./scripts/workspace/cleanup.sh    # Linux
scripts\workspace\cleanup.bat     # Windows
```

**Interactive prompts:**
1. Confirms you want to proceed
2. Asks if you want to connect to your remote repo
3. If yes, asks for Git URL

**Example session:**
```
Continue? (yes/no): yes

[1/5] Removing git remote...
  ✓ Removed origin remote

[2/5] Deleting setup files...
  ✓ Deleted auto-setup.sh
  ✓ Deleted START_WINDOWS.bat
  ✓ Deleted scripts/
  ✓ Deleted docu/

[3/5] Creating new .gitignore...
  ✓ Created new .gitignore

[4/5] Current workspace contents:
images/  projects/  tools/

[5/5] Connect to your remote repo?
Connect to your project repo? (y/n): y
Enter your Git remote URL: https://github.com/username/myproject.git
✓ Connected to: https://github.com/username/myproject.git
```

**What gets deleted:**
- `auto-setup.sh` / `auto-setup.bat`
- `START_WINDOWS.bat` / `start_linux.sh`
- `scripts/` (all setup/build scripts)
- `docu/` (all documentation)
- `config/` (shared configs)
- `.github/` (GitHub workflows)
- `README.md` (setup readme)
- `.gitignore` (old gitignore)

**What gets kept:**
- `images/` (container images)
- `projects/` (your code)
- `tools/` (GUI tools if installed)

**New .gitignore created:**
```gitignore
# Ignore container images (too large for Git)
images/*.tar

# Ignore tools binaries
tools/
vcxsrv/
podman/

# OS and IDE files
.DS_Store
Thumbs.db
.vscode/
```

---

### bailout.sh / bailout.bat

**Purpose:** Safely delete workspace after pushing code

**Usage:**
```bash
./scripts/workspace/bailout.sh    # Linux
scripts\workspace\bailout.bat     # Windows
```

**Safety checks:**

**Check 1: Remote repository**
```bash
git remote get-url origin
```
- ✅ Pass: Remote exists
- ❌ Fail: No remote configured (shows how to add one)

**Check 2: Uncommitted changes**
```bash
git status --porcelain
```
- ✅ Pass: Working directory clean
- ❌ Fail: Uncommitted files (shows `git status` output)

**Check 3: Unpushed commits**
```bash
git rev-list @{u}..HEAD
```
- ✅ Pass: Everything pushed to remote
- ❌ Fail: Unpushed commits (shows commit list)

**Example success:**
```
[Check 1/3] Checking remote repository...
✓ PASSED: Remote configured (https://github.com/user/project.git)

[Check 2/3] Checking for uncommitted changes...
✓ PASSED: No uncommitted changes

[Check 3/3] Checking for unpushed commits...
✓ PASSED: Everything is pushed

All Safety Checks Passed!

Your work is safely backed up to:
  https://github.com/user/project.git

This will DELETE the entire workspace directory:
  /home/user/Portable_Dev_Env_For_School

Type 'DELETE' to confirm: DELETE

Deleting workspace in 3 seconds...
3...
2...
1...
✓ Workspace deleted successfully!
```

**Example failure:**
```
[Check 1/3] Checking remote repository...
✓ PASSED: Remote configured

[Check 2/3] Checking for uncommitted changes...
✗ FAILED: You have uncommitted changes!

Uncommitted files:
M  projects/python/main.py
?? projects/python/new_file.py

Commit them first:
  git add .
  git commit -m 'Your message'
```

---

## Complete Workflow Example

### Scenario: School Assignment

**Monday - Setup:**
```bash
# 1. Clone setup repo on school PC
cd C:\Users\Student\Documents
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
cd Portable_Dev_Env_For_School

# 2. Run auto-setup (downloads images ~2.2 GB, takes 5-10 min)
auto-setup.bat

# 3. Set up devcontainer
scripts\containers\setup_devcontainer.bat all

# 4. Clean up and connect to your repo
scripts\workspace\cleanup.bat
# Prompts: Connect to your repo? y
# Enter: https://github.com/yourusername/assignment1.git

# 5. Start coding
cd projects\python
code .
# F1 → "Reopen in Container"
```

**Tuesday - Continue working:**
```bash
cd C:\Users\Student\Documents\Portable_Dev_Env_For_School
cd projects\python
code .
# Continue coding...
git add .
git commit -m "Added feature"
git push
```

**Friday - Submit and clean up:**
```bash
# Final commit
git add .
git commit -m "Final submission"
git push

# Safely delete workspace
scripts\workspace\bailout.bat
# Checks everything is pushed, then deletes

# Your code is safe on GitHub!
# School PC is clean
```

**At home - Get your code back:**
```bash
git clone https://github.com/yourusername/assignment1.git
cd assignment1
# Your code is here!
```

---

## Why This Workflow?

### Problem: Setup files pollute your project

Without workspace cleanup:
```
YourProject/
├── auto-setup.bat        ← Setup clutter
├── START_WINDOWS.bat     ← Setup clutter
├── scripts/              ← Setup clutter
├── docu/                 ← Setup clutter
└── projects/
    └── python/
        └── your_code.py  ← Your actual work
```

Hard to:
- Share just your project code
- Git commit only your work
- Navigate your own files

### Solution: Clean workspace

After cleanup:
```
YourProject/
├── images/               ← Need these for containers
├── projects/
│   └── python/
│       └── your_code.py  ← Your work
└── tools/                ← Optional GUI tools
```

Easy to:
- Git commit your projects
- Share your code (images are gitignored)
- Focus on your work

---

## Frequently Asked Questions

### Q: Can I skip cleanup and use the repo as-is?

Yes! Cleanup is optional. You can:
- Keep all setup scripts
- Work in `projects/` folder
- Never commit to your own repo

But cleanup is recommended for cleaner workflow.

### Q: What if I want to set up another PC later?

Clone the **setup repo** again on the new PC:
```bash
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
./auto-setup.sh
```

Your **project code** is in your separate repo:
```bash
git clone https://github.com/yourusername/myproject.git
```

### Q: Can I undo cleanup?

No. Cleanup deletes setup files permanently. But you can:
1. Clone the setup repo again
2. Copy your `projects/` folder to it
3. Run cleanup again

### Q: What happens if bailout checks fail?

Bailout **will not delete** if:
- No remote configured → Add with `git remote add origin <url>`
- Uncommitted changes → Commit with `git add . && git commit`
- Unpushed commits → Push with `git push`

Fix the issue and run bailout again.

### Q: Do I need to run bailout?

No! Bailout is optional. It's useful when:
- Using a shared/school PC (leave no trace)
- You're done with the project
- You want to free up disk space

If it's your personal machine, you can keep the workspace.

### Q: Will I lose container images after bailout?

Yes, `.tar` files are deleted. But images remain **loaded in Docker/Podman** until you run:
```bash
docker image rm python-gui java-gui
```

To get images back:
```bash
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git
cd Portable_Dev_Env_For_School
./auto-setup.sh  # Re-downloads images
```

### Q: Can I use cleanup without connecting a remote?

Yes! When prompted, answer `n` (no). You can add remote later:
```bash
git remote add origin https://github.com/username/repo.git
git push -u origin main
```

---

## Troubleshooting

### Cleanup: "Permission denied" errors

**Linux:**
```bash
chmod +x scripts/workspace/cleanup.sh
./scripts/workspace/cleanup.sh
```

**Windows:** Run as administrator or check file permissions

### Bailout: "Branch not pushed to remote"

You need to push your branch first:
```bash
git push -u origin main
```

### Bailout: Script still exists after cleanup

Bailout checks run **before deletion**, so the script deletes itself at the end. If it fails checks, script remains (by design).

### "Images not found" after cleanup

Images are in `images/` folder (kept after cleanup). If missing:
```bash
# Re-download
git clone https://github.com/Be1l-ai/Portable_Dev_Env_For_School.git temp
./temp/auto-setup.sh
cp -r temp/images/* images/
rm -rf temp
```

---

## Related Documentation

- **Dev Containers:** `scripts/containers/README.md` - VS Code setup
- **Git Setup:** `docu/GIT_SETUP.md` - Git-based deployment
- **USB Setup:** `docu/USB_SETUP.md` - USB-based deployment

---

**Summary:**

1. **Clone** setup repo → **auto-setup** → **setup_devcontainer**
2. **cleanup** → Connect to your repo
3. **Code** → Commit → Push
4. **bailout** → Safe deletion

Your code stays safe on Git, school PC stays clean!
