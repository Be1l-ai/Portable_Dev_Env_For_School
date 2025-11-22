#!/bin/bash
# download_images.sh - Download and load container images from GitHub Releases
# Usage: ./download_images.sh [REPO] [VERSION]

set -e

# Configuration (edit these or pass as arguments)
REPO="${1:-Be1l-ai/Portable_Dev_Env_For_School}"
VERSION="${2:-v1.0}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get script directory and navigate to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

echo -e "${GREEN}=== Container Images Download Script ===${NC}"
echo -e "Repository: ${YELLOW}$REPO${NC}"
echo -e "Version: ${YELLOW}$VERSION${NC}"
echo ""

# Check if images directory exists
if [ ! -d "images" ]; then
    echo -e "${YELLOW}Creating images directory...${NC}"
    mkdir -p images
fi

# Check if wget or curl is available
if command -v wget &> /dev/null; then
    DOWNLOADER="wget"
    DOWNLOAD_CMD="wget -c"
elif command -v curl &> /dev/null; then
    DOWNLOADER="curl"
    DOWNLOAD_CMD="curl -L -C - -o"
else
    echo -e "${RED}Error: Neither wget nor curl is available. Please install one of them.${NC}"
    exit 1
fi

echo -e "${GREEN}Using $DOWNLOADER to download files...${NC}"
echo ""

# Download Python container image
PYTHON_URL="https://github.com/$REPO/releases/download/$VERSION/python-gui.tar"
PYTHON_FILE="images/python-gui.tar"

if [ -f "$PYTHON_FILE" ]; then
    echo -e "${YELLOW}Python container image already exists. Skipping download.${NC}"
else
    echo -e "${GREEN}Downloading Python container image (~1.1 GB)...${NC}"
    if [ "$DOWNLOADER" = "wget" ]; then
        wget -c "$PYTHON_URL" -O "$PYTHON_FILE"
    else
        curl -L -C - -o "$PYTHON_FILE" "$PYTHON_URL"
    fi
    echo -e "${GREEN}Python image downloaded successfully!${NC}"
fi

echo ""

# Download Java container image
JAVA_URL="https://github.com/$REPO/releases/download/$VERSION/java-gui.tar"
JAVA_FILE="images/java-gui.tar"

if [ -f "$JAVA_FILE" ]; then
    echo -e "${YELLOW}Java container image already exists. Skipping download.${NC}"
else
    echo -e "${GREEN}Downloading Java container image (~1.1 GB)...${NC}"
    if [ "$DOWNLOADER" = "wget" ]; then
        wget -c "$JAVA_URL" -O "$JAVA_FILE"
    else
        curl -L -C - -o "$JAVA_FILE" "$JAVA_URL"
    fi
    echo -e "${GREEN}Java image downloaded successfully!${NC}"
fi

echo ""

# Check if podman is available
if command -v podman &> /dev/null; then
    echo -e "${GREEN}Loading images into Podman...${NC}"
    
    # Load Python image
    if podman images | grep -q "python-gui"; then
        echo -e "${YELLOW}Python container already loaded in Podman.${NC}"
    else
        echo -e "${GREEN}Loading Python container...${NC}"
        podman load -i "$PYTHON_FILE"
        echo -e "${GREEN}Python container loaded!${NC}"
    fi
    
    # Load Java image
    if podman images | grep -q "java-gui"; then
        echo -e "${YELLOW}Java container already loaded in Podman.${NC}"
    else
        echo -e "${GREEN}Loading Java container...${NC}"
        podman load -i "$JAVA_FILE"
        echo -e "${GREEN}Java container loaded!${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}=== Setup Complete! ===${NC}"
    echo -e "Run ${YELLOW}./start_linux.sh${NC} to start the development environment."
else
    echo -e "${YELLOW}Podman not found. Images downloaded but not loaded.${NC}"
    echo -e "Install Podman with: ${YELLOW}sudo apt install podman${NC} (Ubuntu/Debian)"
    echo -e "or: ${YELLOW}sudo dnf install podman${NC} (Fedora)"
    echo ""
    echo -e "Then load images manually:"
    echo -e "  ${YELLOW}podman load -i $PYTHON_FILE${NC}"
    echo -e "  ${YELLOW}podman load -i $JAVA_FILE${NC}"
fi

echo ""
echo -e "${GREEN}Done!${NC}"
