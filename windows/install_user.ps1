# Cruise_Logs User Installation Script
# PowerShell script for installation in user space (no admin required)
#
# USAGE:
#   powershell -ExecutionPolicy Bypass -File install_user.ps1
#
# This will install Cruise Logs in your user folder at:
#   C:\Users\YourName\Cruise_Logs

param(
    [string]$InstallPath = "$env:USERPROFILE\Cruise_Logs"
)

# ============================================================================
# COLOR OUTPUT FUNCTIONS
# ============================================================================
function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

Write-Header "Cruise Logs User Installer"

Write-Info "This installer will set up Cruise Logs in your user directory"
Write-Info "Installation directory: $InstallPath"
Write-Info ""
Write-Info "No administrator privileges required!"
Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# ============================================================================
# STEP 1: Check for Anaconda
# ============================================================================
Write-Info "STEP 1: Checking for Anaconda..."
Write-Host ""

$CondaPath = $null
$PossiblePaths = @(
    "$env:USERPROFILE\anaconda3",
    "$env:USERPROFILE\miniconda3",
    "C:\anaconda3",
    "C:\miniconda3",
    "C:\ProgramData\Anaconda3",
    "C:\ProgramData\Miniconda3"
)

foreach ($path in $PossiblePaths) {
    if (Test-Path "$path\Scripts\conda.exe") {
        $CondaPath = $path
        Write-Success "Found Conda at: $CondaPath"
        break
    }
}

if (-not $CondaPath) {
    Write-Error "Anaconda/Miniconda not found!"
    Write-Host ""
    Write-Host "=" -ForegroundColor Yellow
    Write-Host "Please install Anaconda from:" -ForegroundColor Yellow
    Write-Host "  https://www.anaconda.com/download/" -ForegroundColor White
    Write-Host ""
    Write-Host "During installation:" -ForegroundColor Yellow
    Write-Host "  1. Choose 'Just Me (recommended)'" -ForegroundColor White
    Write-Host "  2. You can optionally check 'Add Anaconda to PATH'" -ForegroundColor White
    Write-Host "=" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter after installing Anaconda, then run this script again"
    exit 1
}

Write-Host ""

# ============================================================================
# STEP 2: Check for Git
# ============================================================================
Write-Info "STEP 2: Checking for Git..."
Write-Host ""

$GitFound = $false
try {
    $GitVersion = & git --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Git is installed: $GitVersion"
        $GitFound = $true
    }
} catch {
    $GitFound = $false
}

if (-not $GitFound) {
    Write-Error "Git is not installed!"
    Write-Host ""
    Write-Host "=" -ForegroundColor Yellow
    Write-Host "Please install Git from:" -ForegroundColor Yellow
    Write-Host "  https://git-scm.com/download/win" -ForegroundColor White
    Write-Host ""
    Write-Host "During installation:" -ForegroundColor Yellow
    Write-Host "  - Use recommended settings (just keep clicking Next)" -ForegroundColor White
    Write-Host "  - Make sure 'Add Git to PATH' is selected" -ForegroundColor White
    Write-Host "=" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter after installing Git, then run this script again"
    exit 1
}

Write-Host ""

# ============================================================================
# STEP 3: Clone Repository
# ============================================================================
Write-Info "STEP 3: Setting up Cruise Logs files..."
Write-Host ""

if (Test-Path $InstallPath) {
    Write-Warning "Cruise Logs is already installed at: $InstallPath"
    Write-Host ""
    $Response = Read-Host "Do you want to reinstall? This will update to the latest version (yes/no)"

    if ($Response -eq "yes") {
        Write-Info "Removing old installation..."
        try {
            Remove-Item -Recurse -Force $InstallPath -ErrorAction Stop
            Write-Success "Old installation removed"
        } catch {
            Write-Error "Could not remove old installation. Please close any programs using Cruise Logs and try again."
            exit 1
        }
    } else {
        Write-Info "Using existing installation"
        Write-Host ""
        Write-Host "Skipping to environment setup..." -ForegroundColor Yellow
        Write-Host ""
    }
}

if (-not (Test-Path $InstallPath)) {
    Write-Info "Downloading Cruise Logs from GitHub..."
    Write-Info "This may take a few minutes depending on your internet connection..."
    Write-Host ""

    & git clone https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs.git $InstallPath 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Files downloaded successfully"
    } else {
        Write-Error "Failed to download repository"
        Write-Error "Please check your internet connection and try again"
        exit 1
    }
}

Write-Host ""

# ============================================================================
# STEP 4: Create Conda Environment
# ============================================================================
Write-Info "STEP 4: Creating Python Environment..."
Write-Host ""

$CondaCmd = "$CondaPath\Scripts\conda.exe"

# Check if environment already exists
$EnvExists = & $CondaCmd env list | Select-String "cruise_logs"
if ($EnvExists) {
    Write-Info "Environment 'cruise_logs' already exists"
    $Response = Read-Host "Recreate environment? This ensures you have the latest packages (yes/no)"

    if ($Response -eq "yes") {
        Write-Info "Removing old environment..."
        & $CondaCmd remove -n cruise_logs --all -y 2>&1 | Out-Null
        Write-Success "Old environment removed"
        $EnvExists = $false
    }
}

if (-not $EnvExists) {
    Write-Info "Creating 'cruise_logs' environment with Python 3.11..."
    Write-Info "This may take a few minutes..."
    Write-Host ""

    & $CondaCmd create -n cruise_logs python=3.11 -y 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Environment created successfully"
    } else {
        Write-Error "Failed to create environment"
        Write-Error "There may be an issue with your Anaconda installation"
        exit 1
    }
}

Write-Host ""

# ============================================================================
# STEP 5: Install Python Packages
# ============================================================================
Write-Info "STEP 5: Installing Required Packages..."
Write-Host ""

$PipCmd = "$CondaPath\envs\cruise_logs\Scripts\pip.exe"

if (Test-Path "$InstallPath\requirements.txt") {
    Write-Info "Installing packages (streamlit, pandas, etc.)..."
    Write-Info "This may take several minutes on first installation..."
    Write-Host ""

    & $PipCmd install -r "$InstallPath\requirements.txt" 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Success "All packages installed successfully"
    } else {
        Write-Error "Failed to install some packages"
        Write-Warning "You may still be able to use Cruise Logs, but some features might not work"
        Write-Host ""
        Read-Host "Press Enter to continue anyway"
    }
} else {
    Write-Error "requirements.txt not found in $InstallPath"
    Write-Error "The installation may be incomplete"
    exit 1
}

Write-Host ""

# ============================================================================
# STEP 6: Verify Installation
# ============================================================================
Write-Info "STEP 6: Verifying Installation..."
Write-Host ""

Push-Location $InstallPath

# Check database
if (Test-Path "Cruise_Logs.db") {
    $DbSize = (Get-Item "Cruise_Logs.db").Length / 1MB
    if ($DbSize -gt 1) {
        Write-Success "Database file OK ($([math]::Round($DbSize, 2)) MB)"
    } else {
        Write-Warning "Database file is small (may be empty or corrupted)"
    }
} else {
    Write-Warning "Database file not found - will be created on first use"
}

# Check required files
$RequiredFiles = @("cruise_form.py", "launcher.py", "requirements.txt")
$AllFilesFound = $true
foreach ($file in $RequiredFiles) {
    if (Test-Path $file) {
        Write-Success "Found: $file"
    } else {
        Write-Error "Missing: $file"
        $AllFilesFound = $false
    }
}

if (-not $AllFilesFound) {
    Write-Error "Some required files are missing"
    Write-Error "The installation may be incomplete"
    Write-Host ""
    Pop-Location
    exit 1
}

Pop-Location
Write-Host ""

# ============================================================================
# STEP 7: Create Desktop Shortcuts
# ============================================================================
Write-Info "STEP 7: Creating Desktop Shortcuts..."
Write-Host ""

$DesktopPath = [Environment]::GetFolderPath("Desktop")

Write-Info "Shortcuts will make it easy to launch Cruise Logs from your desktop"
$Response = Read-Host "Create desktop shortcuts? (yes/no)"

if ($Response -eq "yes") {
    try {
        $ShellLink = New-Object -ComObject WScript.Shell

        # Main Form Shortcut
        Write-Info "Creating 'Cruise Logs - Main Form' shortcut..."
        $LnkPath = "$DesktopPath\Cruise Logs - Main Form.lnk"
        $Target = "$CondaPath\envs\cruise_logs\Scripts\streamlit.exe"
        $Arguments = "run `"$InstallPath\cruise_form.py`""

        $Link = $ShellLink.CreateShortcut($LnkPath)
        $Link.TargetPath = $Target
        $Link.Arguments = $Arguments
        $Link.WorkingDirectory = $InstallPath
        $Link.Description = "Launch Cruise Logs Main Form"
        $Link.Save()
        Write-Success "Created: Cruise Logs - Main Form"

        # Launcher Shortcut
        Write-Info "Creating 'Cruise Logs - Launcher' shortcut..."
        $LnkPath = "$DesktopPath\Cruise Logs - Launcher.lnk"
        $Target = "$CondaPath\envs\cruise_logs\pythonw.exe"
        $Arguments = "`"$InstallPath\launcher.py`""

        $Link = $ShellLink.CreateShortcut($LnkPath)
        $Link.TargetPath = $Target
        $Link.Arguments = $Arguments
        $Link.WorkingDirectory = $InstallPath
        $Link.Description = "Launch Cruise Logs with GUI Launcher"
        $Link.Save()
        Write-Success "Created: Cruise Logs - Launcher"

        Write-Host ""
        Write-Success "Desktop shortcuts created successfully!"

    } catch {
        Write-Warning "Could not create shortcuts: $_"
        Write-Info "You can still run Cruise Logs manually (see instructions below)"
    }
} else {
    Write-Info "Skipping shortcut creation"
    Write-Info "You can run Cruise Logs manually (see instructions below)"
}

Write-Host ""

# ============================================================================
# COMPLETION
# ============================================================================
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Summary:" -ForegroundColor Green
Write-Host "  Install Path: $InstallPath" -ForegroundColor White
Write-Host "  Environment:  cruise_logs (Python 3.11)" -ForegroundColor White
Write-Host "  User:         $env:USERNAME" -ForegroundColor White
Write-Host ""

Write-Host "How to Launch Cruise Logs:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  EASY WAY:" -ForegroundColor Cyan
if ($Response -eq "yes") {
    Write-Host "    Double-click the 'Cruise Logs - Main Form' icon on your desktop" -ForegroundColor White
} else {
    Write-Host "    Run this installer again and say 'yes' to create shortcuts" -ForegroundColor White
}
Write-Host ""
Write-Host "  MANUAL WAY:" -ForegroundColor Cyan
Write-Host "    1. Open Anaconda Prompt (search for it in Start Menu)" -ForegroundColor White
Write-Host "    2. Type these commands:" -ForegroundColor White
Write-Host "       conda activate cruise_logs" -ForegroundColor Gray
Write-Host "       cd $InstallPath" -ForegroundColor Gray
Write-Host "       streamlit run cruise_form.py" -ForegroundColor Gray
Write-Host ""

if (Test-Path "$InstallPath\windows\USER_GUIDE.md") {
    Write-Host "For more help, see: $InstallPath\windows\USER_GUIDE.md" -ForegroundColor Cyan
} elseif (Test-Path "$InstallPath\windows\FIELD_DEPLOYMENT_GUIDE.md") {
    Write-Host "For more help, see: $InstallPath\windows\FIELD_DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan
} elseif (Test-Path "$InstallPath\README.md") {
    Write-Host "For more help, see: $InstallPath\README.md" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Installation directory: $InstallPath" -ForegroundColor DarkGray
Write-Host ""

Read-Host "Press Enter to exit"
