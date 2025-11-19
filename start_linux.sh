#!/bin/bash
# Portable Dev Environment for Linux
# Starts Podman containers for Python/Java GUI development

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "  Portable Dev Environment (Linux)"
echo "========================================"
echo
echo "Choose your environment:"
echo "  [p] Python + PyQt6"
echo "  [j] Java + Swing"
echo
read -p "Enter your choice (p/j): " choice

case "$choice" in
    p|P)
        echo
        echo "Starting Python container with GUI support..."
        podman run -it --rm \
            -v "$SCRIPT_DIR/projects/python:/workspace" \
            -w /workspace \
            -e DISPLAY=$DISPLAY \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            --name python-dev \
            python-gui bash
        ;;
    j|J)
        echo
        echo "Starting Java container with GUI support..."
        podman run -it --rm \
            -v "$SCRIPT_DIR/projects/java:/workspace" \
            -w /workspace \
            -e DISPLAY=$DISPLAY \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            --name java-dev \
            java-gui bash
        ;;
    *)
        echo "Invalid choice. Please run the script again and choose 'p' or 'j'."
        exit 1
        ;;
esac
