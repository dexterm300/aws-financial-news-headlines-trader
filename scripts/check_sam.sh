#!/bin/bash

# Script to check AWS SAM CLI installation and PATH

echo "Checking AWS SAM CLI installation..."
echo ""

SAM_FOUND=false
SAM_VERSION=""
SAM_CMD=""

# Check if sam command exists
if command -v sam &> /dev/null; then
    SAM_VERSION=$(sam --version 2>&1)
    if [[ $SAM_VERSION == *"SAM CLI"* ]]; then
        SAM_FOUND=true
        SAM_PATH=$(which sam)
        echo "✓ SAM CLI found: $SAM_VERSION"
        echo "  Location: $SAM_PATH"
    fi
fi

if [ "$SAM_FOUND" = false ]; then
    # Check common installation locations
    POSSIBLE_PATHS=(
        "$HOME/.local/bin/sam"
        "/usr/local/bin/sam"
        "$HOME/.pyenv/shims/sam"
    )
    
    for path in "${POSSIBLE_PATHS[@]}"; do
        if [ -f "$path" ]; then
            echo "⚠ SAM CLI found but not in PATH: $path" 1>&2
            echo "  Add this directory to your PATH:" 1>&2
            echo "  $(dirname $path)" 1>&2
            echo "" 1>&2
            echo "  Add to ~/.zshrc or ~/.bashrc:" 1>&2
            echo "  export PATH=\"$(dirname $path):\$PATH\"" 1>&2
            break
        fi
    done
    
    echo "✗ AWS SAM CLI not found in PATH"
    echo ""
    echo "Installation instructions:"
    echo "  1. Ensure Python 3.11+ is installed (run ./scripts/check_python.sh)"
    echo "  2. Install SAM CLI:"
    echo "     python3 -m pip install aws-sam-cli"
    echo "  Or using Homebrew (macOS):"
    echo "     brew install aws-sam-cli"
    echo "  Or using pipx (recommended):"
    echo "     pipx install aws-sam-cli"
    echo "  3. If installed but not found, add to PATH:"
    echo "     export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "     (Add to ~/.zshrc or ~/.bashrc)"
    echo ""
    echo "See README.md for detailed installation instructions"
    exit 1
fi

# Check if SAM CLI can run properly
echo ""
echo "Testing SAM CLI..."
if sam --help &> /dev/null; then
    echo "✓ SAM CLI is working correctly"
else
    echo "⚠ SAM CLI found but may have issues"
fi

echo ""
echo "SAM CLI setup looks good! ✓"

