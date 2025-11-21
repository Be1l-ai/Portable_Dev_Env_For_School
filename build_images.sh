#!/bin/bash
# build_images.sh - Build container images locally
# Usage: ./build_images.sh [python|java|all]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

BUILD_TARGET="${1:-all}"

echo -e "${GREEN}=== Container Image Build Script ===${NC}"
echo ""

# Check if podman is available
if ! command -v podman &> /dev/null; then
    echo -e "${RED}Error: Podman is not installed.${NC}"
    echo -e "Install with: ${YELLOW}sudo apt install podman${NC} (Ubuntu/Debian)"
    echo -e "or: ${YELLOW}sudo dnf install podman${NC} (Fedora)"
    exit 1
fi

# Create images directory if it doesn't exist
mkdir -p images

# Build Python container
build_python() {
    echo -e "${GREEN}Building Python + PyQt6 container...${NC}"
    
    podman build -t python-gui -f - . <<'DOCKERFILE'
FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install Python, PyQt6, and development tools
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-pyqt6 \
    python3-pyqt6.qtsvg \
    pyqt6-dev-tools \
    git \
    curl \
    wget \
    build-essential \
    libxcb-xinerama0 \
    libxcb-cursor0 \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    fonts-dejavu-core \
    && pip3 install --break-system-packages \
        debugpy \
        black \
        pyright \
        pylint \
        pytest \
        ipython \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
DOCKERFILE

    echo -e "${GREEN}Saving Python container to images/python-gui.tar...${NC}"
    podman save python-gui -o images/python-gui.tar
    
    PYTHON_SIZE=$(du -h images/python-gui.tar | cut -f1)
    echo -e "${GREEN}Python container saved! Size: ${YELLOW}$PYTHON_SIZE${NC}"
}

# Build Java container
build_java() {
    echo -e "${GREEN}Building Java + Swing container...${NC}"
    
    podman build -t java-gui -f - . <<'DOCKERFILE'
FROM ubuntu:24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

# Install Java, Maven, Gradle, and development tools
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    maven \
    gradle \
    git \
    curl \
    wget \
    libxext6 \
    libxrender1 \
    libxtst6 \
    libxi6 \
    libxrandr2 \
    libfreetype6 \
    fontconfig \
    fonts-dejavu-core \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
DOCKERFILE

    echo -e "${GREEN}Saving Java container to images/java-gui.tar...${NC}"
    podman save java-gui -o images/java-gui.tar
    
    JAVA_SIZE=$(du -h images/java-gui.tar | cut -f1)
    echo -e "${GREEN}Java container saved! Size: ${YELLOW}$JAVA_SIZE${NC}"
}

# Build based on target
case "$BUILD_TARGET" in
    python)
        build_python
        ;;
    java)
        build_java
        ;;
    all)
        build_python
        echo ""
        build_java
        ;;
    *)
        echo -e "${RED}Invalid target: $BUILD_TARGET${NC}"
        echo -e "Usage: ./build_images.sh [python|java|all]"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}=== Build Complete! ===${NC}"
echo -e "Images saved in ${YELLOW}images/${NC} directory."
echo ""
echo -e "You can now:"
echo -e "  1. Run ${YELLOW}./start_linux.sh${NC} to start using the containers"
echo -e "  2. Upload images/*.tar to GitHub Releases for distribution"
echo -e "  3. Copy the images/ folder to your USB stick"
echo ""
