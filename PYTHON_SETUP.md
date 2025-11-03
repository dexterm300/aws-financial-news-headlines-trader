# Python 3.11 Installation and PATH Configuration Guide

This guide provides detailed instructions for installing Python 3.11+ and ensuring it's properly configured in your system PATH.

## Quick Check

Before installing, check if you already have Python 3.11+:

```bash
# Windows
.\scripts\check_python.ps1

# macOS/Linux
./scripts/check_python.sh
```

If the check passes, you're ready to go! Otherwise, follow the installation steps below.

## Why Python 3.11?

This project uses Python 3.11 as the Lambda runtime, which requires matching Python version locally for:
- Installing dependencies
- Creating virtual environments
- Testing Lambda functions locally
- Building deployment packages

## Installation by Operating System

### Windows

#### Option 1: Official Python Installer (Recommended)

1. **Download Python 3.11+**
   - Visit: https://www.python.org/downloads/
   - Download Python 3.11.x (or newer)
   - Choose Windows installer (64-bit)

2. **Install Python**
   - Run the installer
   - **CRITICAL**: Check ✅ "Add Python to PATH" at the bottom
   - Choose "Install Now" (or "Customize installation" to change location)
   - Wait for installation to complete

3. **Verify Installation**
   ```powershell
   python --version
   # Should show: Python 3.11.x
   
   python -m pip --version
   # Should show pip version
   ```

4. **If PATH Not Set** (if step 2 was missed):
   - Find Python installation directory:
     ```
     C:\Users\YourUsername\AppData\Local\Programs\Python\Python311
     C:\Python311
     ```
   - Add to PATH:
     1. Search "Environment Variables" in Windows
     2. Click "Environment Variables" button
     3. Under "User variables" or "System variables", select "Path"
     4. Click "Edit" → "New"
     5. Add: `C:\Users\YourUsername\AppData\Local\Programs\Python\Python311`
     6. Add: `C:\Users\YourUsername\AppData\Local\Programs\Python\Python311\Scripts`
     7. Click OK on all dialogs
     8. **Restart your terminal/IDE**

#### Option 2: Python Launcher (Windows)

If you have multiple Python versions:

```powershell
# Use Python launcher
py -3.11 --version

# Install packages
py -3.11 -m pip install <package>

# Create venv
py -3.11 -m venv venv
```

### macOS

#### Option 1: Homebrew (Recommended)

```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python 3.11
brew install python@3.11

# Verify
python3.11 --version

# Make it default (optional)
brew link --overwrite python@3.11

# Verify PATH
which python3.11
# Should show: /opt/homebrew/bin/python3.11 or /usr/local/bin/python3.11
```

#### Option 2: Official Python Installer

1. Visit: https://www.python.org/downloads/macos/
2. Download Python 3.11+ installer
3. Run installer and follow prompts
4. Verify:
   ```bash
   python3 --version
   python3 -m pip --version
   ```

#### PATH Configuration (macOS)

If Python is not in PATH:

```bash
# Check current location
which python3.11

# Add to PATH in ~/.zshrc (or ~/.bash_profile for bash)
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

### Linux (Ubuntu/Debian)

```bash
# Update package list
sudo apt-get update

# Install Python 3.11
sudo apt-get install python3.11 python3.11-venv python3.11-pip

# Verify
python3.11 --version
python3.11 -m pip --version

# Make python3 point to 3.11 (optional)
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Verify
python3 --version
```

### Linux (CentOS/RHEL/Fedora)

```bash
# Fedora/RHEL 8+
sudo dnf install python3.11 python3.11-pip

# CentOS/RHEL 7 (may need EPEL)
sudo yum install epel-release
sudo yum install python311 python311-pip

# Verify
python3.11 --version
```

## Verifying PATH Configuration

After installation, verify Python is accessible:

### Windows
```powershell
# Check version
python --version

# Check pip
python -m pip --version

# Check PATH
$env:PATH -split ';' | Select-String Python

# If commands fail, restart terminal
```

### macOS/Linux
```bash
# Check version
python3.11 --version
# or
python3 --version

# Check pip
python3.11 -m pip --version

# Check location
which python3.11

# Check PATH
echo $PATH | grep -i python
```

## Common Issues and Solutions

### Issue: "python: command not found"

**Windows:**
```powershell
# Try Python launcher
py -3.11 --version

# Or use full path
C:\Python311\python.exe --version

# Fix: Add to PATH (see installation steps above)
```

**macOS/Linux:**
```bash
# Try explicit version
python3.11 --version

# Find Python location
find /usr -name python3.11 2>/dev/null
find /opt -name python3.11 2>/dev/null

# Add to PATH in shell profile
```

### Issue: "Wrong Python version"

**Check current version:**
```bash
# Windows
python --version

# macOS/Linux
python3 --version
```

**If showing older version:**
- Windows: Use `py -3.11` or update PATH priority
- macOS: Use `python3.11` explicitly or update Homebrew
- Linux: Use `python3.11` or update alternatives

### Issue: "pip: command not found"

**Solution:**
```bash
# Windows
python -m ensurepip --upgrade

# macOS/Linux
python3.11 -m ensurepip --upgrade

# Or install pip separately
python3.11 -m pip install --upgrade pip
```

### Issue: "Virtual environment uses wrong Python"

**Solution:**
```bash
# Explicitly specify Python version
python3.11 -m venv venv

# Or
py -3.11 -m venv venv  # Windows

# Verify after activation
python --version
```

## Testing Your Installation

Run these commands to verify everything works:

```bash
# 1. Check Python version (should be 3.11+)
python --version  # Windows
python3 --version  # macOS/Linux

# 2. Check pip
python -m pip --version  # Windows
python3 -m pip --version  # macOS/Linux

# 3. Create test virtual environment
python -m venv test_venv  # Windows
python3 -m venv test_venv  # macOS/Linux

# 4. Activate and test
# Windows
test_venv\Scripts\activate
# macOS/Linux
source test_venv/bin/activate

# 5. Verify venv Python
python --version  # Should show 3.11.x

# 6. Install test package
pip install requests

# 7. Clean up
deactivate
rm -rf test_venv  # macOS/Linux
rmdir /s test_venv  # Windows
```

## For This Project

After Python 3.11 is installed and in PATH:

1. **Install Lambda dependencies:**
   ```bash
   # Windows
   .\scripts\install_lambda_deps.ps1
   
   # macOS/Linux
   ./scripts/install_lambda_deps.sh
   ```

2. **Install AWS SAM CLI** (only if using SAM/CloudFormation deployment):
   ```bash
   # Windows
   python -m pip install aws-sam-cli
   
   # macOS/Linux
   python3 -m pip install aws-sam-cli
   
   # Or using pipx (recommended, avoids conflicts)
   pipx install aws-sam-cli
   ```

3. **Verify everything:**
   ```bash
   python --version  # Should be 3.11.x
   sam --version      # Only if using SAM deployment
   ```

> **Note**: AWS SAM CLI is only required for SAM/CloudFormation deployment. If using Terraform, you don't need SAM CLI.

## Need Help?

- Python installation: https://www.python.org/downloads/
- PATH setup: See troubleshooting section above
- Project-specific: See main README.md or QUICKSTART.md

