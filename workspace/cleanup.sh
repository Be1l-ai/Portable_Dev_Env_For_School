#!/bin/bash
# cleanup.sh - Convert setup repo into your workspace
# Removes setup files, keeps images/projects/tools

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Workspace Cleanup Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "This will:"
echo "  1. Remove git remote (disconnect from setup repo)"
echo "  2. Delete setup scripts and documentation"
echo "  3. Keep only: images/, projects/, tools/"
echo "  4. Optionally connect to YOUR project repo"
echo ""
echo -e "${YELLOW}WARNING: This cannot be undone!${NC}"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

# Get repo root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo ""
echo -e "${GREEN}[1/5] Removing git remote...${NC}"
git remote remove origin 2>/dev/null || echo "  No remote to remove"

echo ""
echo -e "${GREEN}[2/5] Deleting setup files...${NC}"

# List of files/folders to delete
TO_DELETE=(
    "auto-setup.sh"
    "auto-setup.bat"
    "START_WINDOWS.bat"
    "start_linux.sh"
    "scripts/"
    "docu/"
    "config/"
    ".github/"
    "README.md"
    ".gitignore"
)

for item in "${TO_DELETE[@]}"; do
    if [ -e "$item" ]; then
        rm -rf "$item"
        echo "  ✓ Deleted $item"
    fi
done

echo ""
echo -e "${GREEN}[3/5] Creating new .gitignore...${NC}"

cat > .gitignore <<'EOF'
# Workspace .gitignore - Only track your projects

# Ignore container images (too large for Git)
images/*.tar

# Ignore tools binaries (download separately)
tools/
vcxsrv/
podman/

# OS files
.DS_Store
Thumbs.db
desktop.ini

# IDE files (keep devcontainer)
.vscode/
!.devcontainer/

# Temporary files
*.log
*.tmp
*~
EOF

echo "  ✓ Created new .gitignore"

echo ""
echo -e "${GREEN}[4/5] Current workspace contents:${NC}"
ls -la

echo ""
echo -e "${GREEN}[5/5] Connect to your remote repo?${NC}"
echo ""
read -p "Connect to your project repo? (y/n): " connect_remote

if [ "$connect_remote" = "y" ] || [ "$connect_remote" = "Y" ]; then
    echo ""
    read -p "Enter your Git remote URL (e.g., https://github.com/username/myproject.git): " remote_url
    
    if [ -n "$remote_url" ]; then
        git remote add origin "$remote_url"
        echo -e "${GREEN}✓ Connected to: $remote_url${NC}"
        echo ""
        echo "To push your work:"
        echo -e "  ${YELLOW}git add .${NC}"
        echo -e "  ${YELLOW}git commit -m 'Initial commit'${NC}"
        echo -e "  ${YELLOW}git push -u origin main${NC}"
    else
        echo -e "${YELLOW}No URL provided, skipping remote setup.${NC}"
    fi
else
    echo -e "${YELLOW}Skipped remote setup. You can add it later with:${NC}"
    echo "  git remote add origin <your-repo-url>"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Cleanup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Your workspace now contains:"
echo "  - projects/    (your code)"
echo "  - images/      (container images)"
echo "  - tools/       (optional GUI tools)"
echo ""
echo "Next steps:"
echo "  1. Start coding in projects/python/ or projects/java/"
echo "  2. Commit your work: git add . && git commit -m 'message'"
echo "  3. Push to remote: git push"
echo ""
echo -e "${YELLOW}When done, run: scripts/workspace/bailout.sh${NC}"
echo ""
