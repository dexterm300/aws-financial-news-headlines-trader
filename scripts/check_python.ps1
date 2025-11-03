# PowerShell script to check Python 3.11+ installation and PATH

Write-Host "Checking Python 3.11+ installation..." -ForegroundColor Cyan
Write-Host ""

$PythonFound = $false
$PythonVersion = $null
$PythonPath = $null

# Try python command
try {
    $versionOutput = python --version 2>&1
    if ($versionOutput -match "Python (\d+)\.(\d+)") {
        $Major = [int]$Matches[1]
        $Minor = [int]$Matches[2]
        if ($Major -ge 3 -and $Minor -ge 11) {
            $PythonVersion = $versionOutput
            $PythonPath = (Get-Command python).Source
            $PythonFound = $true
            Write-Host "✓ Python found: $PythonVersion" -ForegroundColor Green
            Write-Host "  Location: $PythonPath" -ForegroundColor Gray
        }
    }
} catch {
    # Try py launcher
    try {
        $versionOutput = py -3.11 --version 2>&1
        if ($versionOutput) {
            $PythonVersion = $versionOutput
            $PythonPath = "py -3.11 (Python Launcher)"
            $PythonFound = $true
            Write-Host "✓ Python found via launcher: $PythonVersion" -ForegroundColor Green
        }
    } catch {
        # Not found
    }
}

if (-not $PythonFound) {
    Write-Host "✗ Python 3.11+ not found in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Python 3.11+:" -ForegroundColor Yellow
    Write-Host "  1. Download from https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host "  2. IMPORTANT: Check 'Add Python to PATH' during installation" -ForegroundColor Yellow
    Write-Host "  3. Restart terminal after installation" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "See PYTHON_SETUP.md for detailed instructions" -ForegroundColor Yellow
    exit 1
}

# Check pip
Write-Host ""
Write-Host "Checking pip..." -ForegroundColor Cyan
try {
    $pipVersion = python -m pip --version 2>&1
    Write-Host "✓ pip available: $pipVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ pip not available" -ForegroundColor Red
    Write-Host "  Run: python -m ensurepip --upgrade" -ForegroundColor Yellow
}

# Check venv module
Write-Host ""
Write-Host "Checking venv module..." -ForegroundColor Cyan
try {
    python -m venv --help | Out-Null
    Write-Host "✓ venv module available" -ForegroundColor Green
} catch {
    Write-Host "✗ venv module not available" -ForegroundColor Red
}

Write-Host ""
Write-Host "Python setup looks good! ✓" -ForegroundColor Green

