#!/bin/bash
# bailout.sh - Safely delete workspace after pushing
# Only deletes if everything is committed and pushed

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Bailout Script - Safe Deletion${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Get repo root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "Running safety checks..."
echo ""

# Check 1: Is there a remote?
echo -e "${YELLOW}[Check 1/3] Checking remote repository...${NC}"
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
    echo -e "${RED}✗ FAILED: No remote repository configured!${NC}"
    echo ""
    echo "Cannot delete workspace without a backup remote."
    echo "Add a remote first:"
    echo "  git remote add origin <your-repo-url>"
    exit 1
fi

echo -e "${GREEN}✓ PASSED: Remote configured ($REMOTE_URL)${NC}"

# Check 2: Any uncommitted changes?
echo -e "${YELLOW}[Check 2/3] Checking for uncommitted changes...${NC}"
UNCOMMITTED=$(git status --porcelain)

if [ -n "$UNCOMMITTED" ]; then
    echo -e "${RED}✗ FAILED: You have uncommitted changes!${NC}"
    echo ""
    echo "Uncommitted files:"
    git status --short
    echo ""
    echo "Commit them first:"
    echo "  git add ."
    echo "  git commit -m 'Your message'"
    exit 1
fi

echo -e "${GREEN}✓ PASSED: No uncommitted changes${NC}"

# Check 3: Any unpushed commits?
echo -e "${YELLOW}[Check 3/3] Checking for unpushed commits...${NC}"

# Check if branch has upstream
UPSTREAM=$(git rev-parse --abbrev-ref @{u} 2>/dev/null || echo "")

if [ -z "$UPSTREAM" ]; then
    echo -e "${RED}✗ FAILED: Branch not pushed to remote!${NC}"
    echo ""
    echo "Push your branch first:"
    echo "  git push -u origin $(git branch --show-current)"
    exit 1
fi

# Check for unpushed commits
UNPUSHED=$(git rev-list @{u}..HEAD 2>/dev/null || echo "")

if [ -n "$UNPUSHED" ]; then
    COMMIT_COUNT=$(echo "$UNPUSHED" | wc -l)
    echo -e "${RED}✗ FAILED: You have $COMMIT_COUNT unpushed commit(s)!${NC}"
    echo ""
    echo "Unpushed commits:"
    git log @{u}..HEAD --oneline
    echo ""
    echo "Push them first:"
    echo "  git push"
    exit 1
fi

echo -e "${GREEN}✓ PASSED: Everything is pushed${NC}"

# All checks passed
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  All Safety Checks Passed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Your work is safely backed up to:"
echo "  $REMOTE_URL"
echo ""
echo -e "${RED}This will DELETE the entire workspace directory:${NC}"
echo "  $REPO_ROOT"
echo ""
echo -e "${YELLOW}Are you absolutely sure?${NC}"
read -p "Type 'DELETE' to confirm: " confirm

if [ "$confirm" != "DELETE" ]; then
    echo "Cancelled. Workspace not deleted."
    exit 0
fi

echo ""
echo -e "${YELLOW}Deleting workspace in 3 seconds...${NC}"
sleep 1
echo "3..."
sleep 1
echo "2..."
sleep 1
echo "1..."

# Delete the entire directory (go up one level first)
cd ..
WORKSPACE_NAME=$(basename "$REPO_ROOT")

rm -rf "$REPO_ROOT"

echo ""
echo -e "${GREEN}✓ Workspace deleted successfully!${NC}"
echo ""
echo "Your code is safe at: $REMOTE_URL"
echo "To get it back: git clone $REMOTE_URL"
echo ""
