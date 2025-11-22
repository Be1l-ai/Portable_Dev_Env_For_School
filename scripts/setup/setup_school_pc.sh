#!/bin/bash
# setup_school_pc.sh - Automated setup for school PC (Linux)
# Run this ONCE on each school PC to set up the development environment

set -e

echo "========================================"
echo "  School PC Setup - Docker/Podman"
echo "========================================"
echo
echo "This script will:"
echo "  1. Install Docker or Podman"
echo "  2. Load container images from USB"
echo "  3. Set up user permissions"
echo
read -p "Press Enter to continue..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================
# Step 1: Check if container runtime exists
# ============================================
echo
echo "[Step 1/3] Checking for container runtime..."

RUNTIME=""
if command -v docker &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Docker is already installed"
    RUNTIME="docker"
elif command -v podman &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Podman is already installed"
    RUNTIME="podman"
else
    echo -e "  ${RED}✗${NC} No container runtime found"
    echo
    echo "Which would you like to install?"
    echo "  [1] Podman (recommended, no daemon)"
    echo "  [2] Docker (more common, requires daemon)"
    echo "  [3] Skip installation (I'll do it manually)"
    echo
    read -p "Choose (1/2/3): " runtime_choice
    
    case $runtime_choice in
        1)
            echo
            echo "Installing Podman..."
            sudo apt update
            sudo apt install -y podman
            RUNTIME="podman"
            echo -e "  ${GREEN}✓${NC} Podman installed"
            ;;
        2)
            echo
            echo "Installing Docker..."
            sudo apt update
            sudo apt install -y docker.io
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            RUNTIME="docker"
            echo -e "  ${GREEN}✓${NC} Docker installed"
            echo -e "  ${YELLOW}Note:${NC} Log out and back in for group permissions to take effect"
            echo -e "  Or run: ${YELLOW}newgrp docker${NC}"
            ;;
        3)
            echo
            echo "Please install Docker or Podman manually:"
            echo "  Podman: sudo apt install podman"
            echo "  Docker: sudo apt install docker.io"
            exit 0
            ;;
        *)
            echo "Invalid choice"
            exit 1
            ;;
    esac
fi

echo
echo "Using: $RUNTIME"

# ============================================
# Step 2: Find USB drive
# ============================================
echo
echo "[Step 2/3] Looking for USB drive with container images..."

USB_DRIVE=""
# Check common mount points
for mount_point in /media/$USER/* /run/media/$USER/* /mnt/*; do
    if [ -f "$mount_point/images/python-gui.tar" ]; then
        USB_DRIVE="$mount_point"
        break
    fi
done

if [ -z "$USB_DRIVE" ]; then
    echo -e "  ${RED}✗${NC} USB drive not found"
    echo
    echo "Please:"
    echo "  1. Insert your USB drive"
    echo "  2. Make sure it contains images/python-gui.tar and images/java-gui.tar"
    echo "  3. Run this script again"
    echo
    echo "Or specify the path manually:"
    read -p "USB mount point (or press Enter to exit): " manual_path
    if [ -n "$manual_path" ] && [ -f "$manual_path/images/python-gui.tar" ]; then
        USB_DRIVE="$manual_path"
    else
        exit 1
    fi
fi

echo -e "  ${GREEN}✓${NC} Found USB at $USB_DRIVE"

# ============================================
# Step 3: Load container images
# ============================================
echo
echo "[Step 3/3] Loading container images..."
echo "This may take 2-3 minutes..."
echo

# Check if images already loaded
if $RUNTIME images | grep -q "python-gui"; then
    echo -e "  ${GREEN}✓${NC} python-gui already loaded"
else
    echo "Loading python-gui.tar (~1.8 GB)..."
    $RUNTIME load -i "$USB_DRIVE/images/python-gui.tar"
    echo -e "  ${GREEN}✓${NC} python-gui loaded successfully"
fi

echo

if $RUNTIME images | grep -q "java-gui"; then
    echo -e "  ${GREEN}✓${NC} java-gui already loaded"
else
    echo "Loading java-gui.tar (~1.6 GB)..."
    $RUNTIME load -i "$USB_DRIVE/images/java-gui.tar"
    echo -e "  ${GREEN}✓${NC} java-gui loaded successfully"
fi

echo
echo "========================================"
echo "  Setup Complete!"
echo "========================================"
echo
echo "Container images are now loaded on this PC."
echo
echo "Daily usage:"
echo "  1. Plug in your USB"
echo "  2. Run: $USB_DRIVE/start_linux.sh"
echo "  3. Choose Python or Java"
echo "  4. Start coding!"
echo
echo "Images loaded:"
$RUNTIME images | grep -E "(REPOSITORY|python-gui|java-gui)"
echo

if [ "$RUNTIME" = "docker" ]; then
    echo -e "${YELLOW}Note:${NC} If you installed Docker, log out and back in for permissions to work."
    echo "Or run: newgrp docker"
fi
