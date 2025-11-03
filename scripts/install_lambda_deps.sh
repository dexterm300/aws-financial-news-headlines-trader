#!/bin/bash

# Script to install Python dependencies for all Lambda functions

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAMBDA_DIRS=(
    "src/news_ingestion"
    "src/bedrock_analysis"
    "src/websocket_connect"
    "src/websocket_disconnect"
    "src/websocket_message"
    "src/get_news"
)

# Check for Python 3.11+
echo "Checking Python installation..."
if command -v python3.11 &> /dev/null; then
    PYTHON_CMD="python3.11"
    PYTHON_VERSION=$(python3.11 --version 2>&1)
elif command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    # Check if it's 3.11+
    PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d' ' -f2 | cut -d'.' -f1)
    PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d' ' -f2 | cut -d'.' -f2)
    if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 11 ]; then
        PYTHON_CMD="python3"
    else
        echo "ERROR: Python 3.11+ required. Found: $PYTHON_VERSION"
        echo "Please install Python 3.11+ and ensure it's in PATH"
        exit 1
    fi
else
    echo "ERROR: Python 3.11+ not found in PATH"
    echo "Please install Python 3.11+ and ensure it's in PATH"
    echo "See README.md for installation instructions"
    exit 1
fi

echo "Using: $PYTHON_VERSION"
echo "Installing dependencies for Lambda functions..."

for dir in "${LAMBDA_DIRS[@]}"; do
    full_path="${BASE_DIR}/${dir}"
    if [ -d "$full_path" ] && [ -f "$full_path/requirements.txt" ]; then
        echo "Installing dependencies for $dir..."
        cd "$full_path"
        
        # Create virtual environment with Python 3.11+
        $PYTHON_CMD -m venv venv
        
        # Activate and install
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
            source venv/Scripts/activate
        else
            source venv/bin/activate
        fi
        
        pip install --upgrade pip
        pip install -r requirements.txt
        
        deactivate
        echo "✓ Completed $dir"
    else
        echo "⚠ Skipping $dir (no requirements.txt found)"
    fi
done

echo ""
echo "All dependencies installed successfully!"
echo ""
echo "Note: Virtual environments are created in each Lambda directory."
echo "Terraform will package everything when you run 'terraform apply'."

