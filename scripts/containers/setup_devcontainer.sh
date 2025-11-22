#!/bin/bash
# setup_devcontainer.sh - Create VS Code Dev Container configurations
# Usage: ./setup_devcontainer.sh [python|java|all]

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SETUP_TARGET="${1:-all}"

# Get script directory and navigate to repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

echo -e "${GREEN}=== Dev Container Setup Script ===${NC}"
echo ""

# Create Python devcontainer config
setup_python() {
    echo -e "${GREEN}Setting up Python Dev Container...${NC}"
    
    mkdir -p projects/python/.devcontainer
    
    cat > projects/python/.devcontainer/devcontainer.json <<'EOF'
{
  "name": "Python PyQt6 Development",
  "image": "python-gui",
  "workspaceFolder": "/workspace",
  
  "mounts": [
    "source=${localWorkspaceFolder},target=/workspace,type=bind"
  ],
  
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-python.debugpy",
        "ms-python.black-formatter",
        "charliermarsh.ruff"
      ],
      "settings": {
        "python.defaultInterpreterPath": "/usr/bin/python3",
        "python.formatting.provider": "black",
        "python.linting.enabled": true,
        "python.linting.pylintEnabled": true,
        "editor.formatOnSave": true
      }
    }
  },
  
  "forwardPorts": [],
  
  "postCreateCommand": "pip3 list",
  
  "remoteUser": "root"
}
EOF

    echo -e "${GREEN}✓ Created projects/python/.devcontainer/devcontainer.json${NC}"
}

# Create Java devcontainer config
setup_java() {
    echo -e "${GREEN}Setting up Java Dev Container...${NC}"
    
    mkdir -p projects/java/.devcontainer
    
    cat > projects/java/.devcontainer/devcontainer.json <<'EOF'
{
  "name": "Java Swing Development",
  "image": "java-gui",
  "workspaceFolder": "/workspace",
  
  "mounts": [
    "source=${localWorkspaceFolder},target=/workspace,type=bind"
  ],
  
  "customizations": {
    "vscode": {
      "extensions": [
        "vscjava.vscode-java-pack",
        "vscjava.vscode-maven",
        "vscjava.vscode-gradle",
        "redhat.java"
      ],
      "settings": {
        "java.home": "/usr/lib/jvm/java-21-openjdk-amd64",
        "java.configuration.runtimes": [
          {
            "name": "JavaSE-21",
            "path": "/usr/lib/jvm/java-21-openjdk-amd64",
            "default": true
          }
        ],
        "maven.executable.path": "/usr/bin/mvn",
        "java.debug.settings.hotCodeReplace": "auto"
      }
    }
  },
  
  "forwardPorts": [],
  
  "postCreateCommand": "java -version && mvn -version",
  
  "remoteUser": "root"
}
EOF

    echo -e "${GREEN}✓ Created projects/java/.devcontainer/devcontainer.json${NC}"
}

# Setup based on target
case "$SETUP_TARGET" in
    python)
        setup_python
        ;;
    java)
        setup_java
        ;;
    all)
        setup_python
        setup_java
        ;;
    *)
        echo -e "${YELLOW}Invalid target: $SETUP_TARGET${NC}"
        echo "Usage: ./setup_devcontainer.sh [python|java|all]"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}=== Dev Container Setup Complete! ===${NC}"
echo ""
echo "To use with VS Code:"
echo -e "  1. Install ${YELLOW}Dev Containers${NC} extension (ms-vscode-remote.remote-containers)"
echo -e "  2. Make sure container images are loaded: ${YELLOW}docker images${NC} or ${YELLOW}podman images${NC}"
echo -e "  3. Open ${YELLOW}projects/python/${NC} or ${YELLOW}projects/java/${NC} in VS Code"
echo -e "  4. Press ${YELLOW}F1${NC} → 'Dev Containers: Reopen in Container'"
echo -e "  5. VS Code will connect to your container and you can code with full IntelliSense!"
echo ""
