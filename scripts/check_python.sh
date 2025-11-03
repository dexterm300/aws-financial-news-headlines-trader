#!/bin/bash

# Script to check Python 3.11+ installation and PATH

echo "Checking Python 3.11+ installation..."
echo ""

PYTHON_FOUND=false
PYTHON_VERSION=""
PYTHON_CMD=""

# Check for python3.11
if command -v python3.11 &> /dev/null; then
    PYTHON_CMD="python3.11"
    PYTHON_VERSION=$(python3.11 --version 2>&1)
    PYTHON_FOUND=true
    PYTHON_PATH=$(which python3.11)
    echo "✓ Python found: $PYTHON_VERSION"
    echo "  Location: $PYTHON_PATH"
elif command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    # Check version
    if [[ $PYTHON_VERSION =~ Python\ ([0-9]+)\.([0-9]+) ]]; then
        MAJOR=${BASH_REMATCH[1]}
        MINOR=${BASH_REMATCH[2]}
        if [ "$MAJOR" -ge 3 ] && [ "$MINOR" -ge 11 ]; then
            PYTHON_CMD="python3"
            PYTHON_FOUND=true
            PYTHON_PATH=$(which python3)
            echo "✓ Python found: $PYTHON_VERSION"
            echo "  Location: $PYTHON_PATH"
        fi
    fi
fi

if [ "$PYTHON_FOUND" = false ]; then
    echo "✗ Python 3.11+ not found in PATH"
    echo ""
    echo "Please install Python 3.11+:"
    echo "  macOS:   brew install python@3.11"
    echo "  Ubuntu:  sudo apt-get install python3.11 python3.11-pip"
    echo "  Or download from https://www.python.org/downloads/"
    echo ""
    echo "See PYTHON_SETUP.md for detailed instructions"
    exit 1
fi

# Check pip
echo ""
echo "Checking pip..."
if $PYTHON_CMD -m pip --version &> /dev/null; then
    PIP_VERSION=$($PYTHON_CMD -m pip --version)
    echo "✓ pip available: $PIP_VERSION"
else
    echo "✗ pip not available"
    echo "  Run: $PYTHON_CMD -m ensurepip --upgrade"
fi

# Check venv module
echo ""
echo "Checking venv module..."
if $PYTHON_CMD -m venv --help &> /dev/null; then
    echo "✓ venv module available"
else
    echo "✗ venv module not available"
fi

echo ""
echo "Python setup looks good! ✓"

