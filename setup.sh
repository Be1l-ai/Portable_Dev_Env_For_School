#!/bin/bash
# setup.sh - Initial setup script to make all scripts executable
# Run this once after cloning the repository on Linux

set -e

echo "========================================="
echo "  Portable Dev Environment Setup"
echo "========================================="
echo ""

# Make shell scripts executable
echo "Making scripts executable..."
chmod +x start_linux.sh
chmod +x download_images.sh
chmod +x build_images.sh

echo "✓ start_linux.sh"
echo "✓ download_images.sh"
echo "✓ build_images.sh"
echo ""

# Create directories if they don't exist
echo "Creating directories..."
mkdir -p images
mkdir -p projects/python
mkdir -p projects/java
mkdir -p config
mkdir -p podman
mkdir -p vcxsrv
mkdir -p tools

echo "✓ images/"
echo "✓ projects/python/"
echo "✓ projects/java/"
echo "✓ config/"
echo "✓ podman/"
echo "✓ vcxsrv/"
echo "✓ tools/"
echo ""

echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Choose your setup method:"
echo "   - USB Setup: See USB_SETUP.md"
echo "   - Git Setup: See GIT_SETUP.md"
echo ""
echo "2. For Git setup, download container images:"
echo "   ./download_images.sh Be1l-ai/Portable_Dev_Env_For_School v1.0"
echo ""
echo "3. Or build images from scratch:"
echo "   ./build_images.sh"
echo ""
echo "4. Start the environment:"
echo "   ./start_linux.sh"
echo ""
