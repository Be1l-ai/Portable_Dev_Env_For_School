#!/bin/bash
# auto-setup.sh - Master automation script for Linux
# Automatically sets up everything in the correct order

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory (repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   Portable Dev Environment - Auto Setup${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "This script will automatically:"
echo "  1. Check container runtime (Docker/Podman)"
echo "  2. Detect USB mount"
echo "  3. Check/build/download container images"
echo "  4. Load images into container runtime"
echo "  5. Launch the development environment"
echo ""
read -p "Press Enter to continue..."

# ============================================
# Step 1: Check container runtime (MUST BE FIRST)
# ============================================
echo ""
echo -e "${GREEN}[Step 1/5] Checking container runtime...${NC}"

if command -v podman &> /dev/null; then
    RUNTIME="podman"
    echo -e "  ${GREEN}✓${NC} Podman found"
elif command -v docker &> /dev/null; then
    RUNTIME="docker"
    echo -e "  ${GREEN}✓${NC} Docker found"
else
    echo -e "  ${RED}✗${NC} No container runtime found"
    echo ""
    echo "Please install Podman or Docker:"
    echo "  Ubuntu/Debian: sudo apt install podman"
    echo "  Fedora: sudo dnf install podman"
    echo "  Docker: https://docs.docker.com/engine/install/"
    exit 1
fi

# ============================================
# Step 2: Detect USB mount
# ============================================
echo ""
echo -e "${GREEN}[Step 2/5] Detecting USB drive...${NC}"

USB_MOUNT=""
# Check common mount points
for mount_point in /run/media/$USER/* /media/$USER/* /mnt/*; do
    if [ -f "$mount_point/START_WINDOWS.bat" ] || [ -d "$mount_point/projects" ]; then
        USB_MOUNT="$mount_point"
        break
    fi
done

if [ -n "$USB_MOUNT" ]; then
    echo -e "  ${GREEN}✓${NC} USB drive detected at $USB_MOUNT"
    USB_MODE=1
else
    echo -e "  ${YELLOW}⚠${NC} USB drive not detected"
    echo -e "  Running from: $SCRIPT_DIR"
    USB_MODE=0
fi

# ============================================
# Step 3: Check for container images
# ============================================
echo ""
echo -e "${GREEN}[Step 3/5] Checking container images...${NC}"

IMAGES_EXIST=0
IMAGE_LOCATION=""

# Check USB first if available
if [ $USB_MODE -eq 1 ]; then
    if [ -f "$USB_MOUNT/images/python-gui.tar" ] && [ -f "$USB_MOUNT/images/java-gui.tar" ]; then
        IMAGES_EXIST=1
        IMAGE_LOCATION="$USB_MOUNT/images"
        echo -e "  ${GREEN}✓${NC} Container images found on USB"
    fi
fi

# Check local images folder if not found on USB
if [ $IMAGES_EXIST -eq 0 ]; then
    if [ -f "images/python-gui.tar" ] && [ -f "images/java-gui.tar" ]; then
        IMAGES_EXIST=1
        IMAGE_LOCATION="images"
        echo -e "  ${GREEN}✓${NC} Container images found locally"
    fi
fi

if [ $IMAGES_EXIST -eq 0 ]; then
    echo -e "  ${RED}✗${NC} Container images not found"
    echo ""
    echo "Choose how to get container images:"
    echo "  [1] Download from GitHub Releases (~2.2 GB, 3-5 minutes)"
    echo "  [2] Build locally (requires Podman, 10-15 minutes)"
    echo "  [3] Skip (I'll add them manually later)"
    echo ""
    read -p "Choose (1/2/3): " image_choice
    
    case "$image_choice" in
        1)
            echo ""
            echo "Downloading images from GitHub..."
            bash scripts/build/download_images.sh
            if [ $? -eq 0 ]; then
                IMAGE_LOCATION="images"
                IMAGES_EXIST=1
            fi
            ;;
        2)
            echo ""
            echo "Building images..."
            echo "This will take 15-20 minutes."
            read -p "Continue? (y/n): " confirm_build
            if [ "$confirm_build" = "y" ] || [ "$confirm_build" = "Y" ]; then
                bash scripts/build/build_images.sh all
                if [ $? -eq 0 ]; then
                    IMAGE_LOCATION="images"
                    IMAGES_EXIST=1
                fi
            fi
            ;;
        *)
            echo ""
            echo "Skipping image setup. You'll need to add images manually."
            IMAGES_EXIST=0
            ;;
    esac
fi

# ============================================
# Step 4: Load images into container runtime
# ============================================
echo ""
echo -e "${GREEN}[Step 4/5] Loading images into $RUNTIME...${NC}"

if [ $IMAGES_EXIST -eq 0 ]; then
    echo -e "  ${YELLOW}⚠${NC} No images to load (skipped)"
else
    PYTHON_LOADED=0
    JAVA_LOADED=0

    if $RUNTIME images | grep -q "python-gui"; then
        echo -e "  ${GREEN}✓${NC} python-gui already loaded"
        PYTHON_LOADED=1
    else
        echo "Loading python-gui.tar..."
        $RUNTIME load -i "$IMAGE_LOCATION/python-gui.tar"
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}✓${NC} python-gui loaded"
            PYTHON_LOADED=1
        else
            echo -e "  ${RED}✗${NC} Failed to load python-gui"
            PYTHON_LOADED=0
        fi
    fi

    if $RUNTIME images | grep -q "java-gui"; then
        echo -e "  ${GREEN}✓${NC} java-gui already loaded"
        JAVA_LOADED=1
    else
        echo "Loading java-gui.tar..."
        $RUNTIME load -i "$IMAGE_LOCATION/java-gui.tar"
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}✓${NC} java-gui loaded"
            JAVA_LOADED=1
        else
            echo -e "  ${RED}✗${NC} Failed to load java-gui"
            JAVA_LOADED=0
        fi
    fi
fi

# ============================================
# Step 5: Launch development environment
# ============================================
echo ""
echo -e "${GREEN}[Step 5/5] Ready to launch...${NC}"
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}   Setup Complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "Container runtime: $RUNTIME"
if [ $USB_MODE -eq 1 ]; then
    echo "USB drive: $USB_MOUNT"
fi
if [ $IMAGES_EXIST -eq 1 ]; then
    echo "Images loaded: ✓"
else
    echo "Images loaded: ✗ (add manually or rerun setup)"
fi
echo ""
read -p "Press Enter to launch..."

# Launch the main launcher
if [ $USB_MODE -eq 1 ]; then
    if [ -f "$USB_MOUNT/start_linux.sh" ]; then
        bash "$USB_MOUNT/start_linux.sh"
    else
        bash start_linux.sh
    fi
else
    bash start_linux.sh
fi
