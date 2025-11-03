# PowerShell script to install Python dependencies for all Lambda functions

$ErrorActionPreference = "Stop"

# Check for Python 3.11+
Write-Host "Checking Python installation..." -ForegroundColor Cyan

$PythonCmd = $null
$PythonVersion = $null

# Try python command first
try {
    $PythonVersion = python --version 2>&1
    if ($PythonVersion -match "Python (\d+)\.(\d+)") {
        $Major = [int]$Matches[1]
        $Minor = [int]$Matches[2]
        if ($Major -ge 3 -and $Minor -ge 11) {
            $PythonCmd = "python"
            Write-Host "Found: $PythonVersion" -ForegroundColor Green
        }
    }
} catch {
    # python not found, try py launcher
    try {
        $PythonVersion = py -3.11 --version 2>&1
        if ($PythonVersion) {
            $PythonCmd = "py -3.11"
            Write-Host "Found: $PythonVersion (via py launcher)" -ForegroundColor Green
        }
    } catch {
        Write-Host "ERROR: Python 3.11+ not found in PATH" -ForegroundColor Red
        Write-Host "Please install Python 3.11+ and ensure it's in PATH" -ForegroundColor Yellow
        Write-Host "See README.md for installation instructions" -ForegroundColor Yellow
        exit 1
    }
}

if (-not $PythonCmd) {
    Write-Host "ERROR: Python 3.11+ required. Found: $PythonVersion" -ForegroundColor Red
    Write-Host "Please install Python 3.11+ and ensure it's in PATH" -ForegroundColor Yellow
    exit 1
}

$BaseDir = Split-Path -Parent $PSScriptRoot
$LambdaDirs = @(
    "src/news_ingestion",
    "src/bedrock_analysis",
    "src/websocket_connect",
    "src/websocket_disconnect",
    "src/websocket_message",
    "src/get_news"
)

Write-Host "Installing dependencies for Lambda functions..." -ForegroundColor Cyan

foreach ($dir in $LambdaDirs) {
    $FullPath = Join-Path $BaseDir $dir
    $RequirementsFile = Join-Path $FullPath "requirements.txt"
    
    if (Test-Path $FullPath -PathType Container) {
        if (Test-Path $RequirementsFile) {
            Write-Host "Installing dependencies for $dir..." -ForegroundColor Yellow
            
            Push-Location $FullPath
            
            # Create virtual environment
            if (Test-Path "venv") {
                Remove-Item -Recurse -Force "venv"
            }
            
            # Use detected Python command
            if ($PythonCmd -match "py -3.11") {
                py -3.11 -m venv venv
                & ".\venv\Scripts\Activate.ps1"
                py -3.11 -m pip install --upgrade pip
                py -3.11 -m pip install -r requirements.txt
            } else {
                python -m venv venv
                & ".\venv\Scripts\Activate.ps1"
                python -m pip install --upgrade pip
                pip install -r requirements.txt
            }
            deactivate
            
            Pop-Location
            Write-Host "✓ Completed $dir" -ForegroundColor Green
        } else {
            Write-Host "⚠ Skipping $dir (no requirements.txt found)" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "All dependencies installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Note: Virtual environments are created in each Lambda directory."
Write-Host "Terraform will package everything when you run 'terraform apply'."

