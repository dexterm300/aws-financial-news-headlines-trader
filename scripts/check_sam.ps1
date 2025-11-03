# PowerShell script to check AWS SAM CLI installation and PATH

Write-Host "Checking AWS SAM CLI installation..." -ForegroundColor Cyan
Write-Host ""

$SamFound = $false
$SamVersion = $null
$SamPath = $null

# Check if sam command exists
try {
    $versionOutput = sam --version 2>&1
    if ($versionOutput -match "SAM CLI") {
        $SamVersion = $versionOutput.Trim()
        try {
            $SamPath = (Get-Command sam).Source
        } catch {
            $SamPath = "Found in PATH"
        }
        $SamFound = $true
        Write-Host "✓ SAM CLI found: $SamVersion" -ForegroundColor Green
        if ($SamPath -ne "Found in PATH") {
            Write-Host "  Location: $SamPath" -ForegroundColor Gray
        }
    }
} catch {
    # Check if it might be in Python Scripts but not in PATH
    $PossiblePaths = @(
        "$env:LOCALAPPDATA\Programs\Python\Python311\Scripts\sam.exe",
        "$env:APPDATA\Python\Python311\Scripts\sam.exe",
        "C:\Python311\Scripts\sam.exe"
    )
    
    foreach ($path in $PossiblePaths) {
        if (Test-Path $path) {
            Write-Host "⚠ SAM CLI found but not in PATH: $path" -ForegroundColor Yellow
            Write-Host "  Add this directory to your PATH:" -ForegroundColor Yellow
            Write-Host "  $(Split-Path $path -Parent)" -ForegroundColor Yellow
            break
        }
    }
}

if (-not $SamFound) {
    Write-Host "✗ AWS SAM CLI not found in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installation instructions:" -ForegroundColor Yellow
    Write-Host "  1. Ensure Python 3.11+ is installed (run .\scripts\check_python.ps1)" -ForegroundColor Yellow
    Write-Host "  2. Install SAM CLI:" -ForegroundColor Yellow
    Write-Host "     python -m pip install aws-sam-cli" -ForegroundColor Yellow
    Write-Host "  3. If installed but not found, add Python Scripts to PATH:" -ForegroundColor Yellow
    Write-Host "     Usually: C:\Users\$env:USERNAME\AppData\Local\Programs\Python\Python311\Scripts" -ForegroundColor Yellow
    Write-Host "  4. Restart terminal after PATH changes" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "See README.md for detailed installation instructions" -ForegroundColor Yellow
    exit 1
}

# Check if SAM CLI can run properly
Write-Host ""
Write-Host "Testing SAM CLI..." -ForegroundColor Cyan
try {
    $helpOutput = sam --help 2>&1 | Select-Object -First 1
    Write-Host "✓ SAM CLI is working correctly" -ForegroundColor Green
} catch {
    Write-Host "⚠ SAM CLI found but may have issues" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "SAM CLI setup looks good! ✓" -ForegroundColor Green

