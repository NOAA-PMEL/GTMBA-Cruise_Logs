# GitHub SSH Setup Script for Cruise_Logs
# Automates SSH key generation and GitHub configuration
#
# USAGE:
#   powershell -ExecutionPolicy Bypass -File setup_github_ssh.ps1

param(
    [string]$Email = "",
    [string]$InstallPath = "C:\Cruise_Logs"
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

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host ">>> $Message" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

Write-Header "GitHub SSH Setup for Cruise_Logs"

Write-Info "This script will:"
Write-Host "  1. Generate SSH keys for GitHub (if needed)" -ForegroundColor White
Write-Host "  2. Configure Git to use SSH" -ForegroundColor White
Write-Host "  3. Switch the repository to use SSH" -ForegroundColor White
Write-Host "  4. Test the connection" -ForegroundColor White
Write-Host ""

# ============================================================================
# STEP 1: Check for Git
# ============================================================================
Write-Step "STEP 1: Checking for Git..."

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
    Write-Info "Please install Git from: https://git-scm.com/download/win"
    exit 1
}

# ============================================================================
# STEP 2: Get User Email
# ============================================================================
Write-Step "STEP 2: Getting User Information..."

if (-not $Email) {
    $Email = Read-Host "Enter your GitHub email address"
}

if (-not $Email -or $Email -notmatch "^[^@]+@[^@]+\.[^@]+$") {
    Write-Error "Invalid email address!"
    exit 1
}

Write-Success "Email: $Email"

# Configure Git
& git config --global user.email $Email
$GitName = & git config --global user.name
if (-not $GitName) {
    $GitName = Read-Host "Enter your name (for Git commits)"
    & git config --global user.name $GitName
}
Write-Success "Git configured for: $GitName <$Email>"

# ============================================================================
# STEP 3: Check/Generate SSH Keys
# ============================================================================
Write-Step "STEP 3: Setting up SSH Keys..."

$SshDir = "$env:USERPROFILE\.ssh"
$KeyFile = "$SshDir\id_ed25519"
$PubKeyFile = "$KeyFile.pub"

# Create .ssh directory if it doesn't exist
if (-not (Test-Path $SshDir)) {
    Write-Info "Creating .ssh directory..."
    New-Item -ItemType Directory -Path $SshDir | Out-Null
}

# Check if key already exists
if (Test-Path $KeyFile) {
    Write-Warning "SSH key already exists at: $KeyFile"
    $Response = Read-Host "Use existing key? (yes/no)"

    if ($Response -ne "yes") {
        Write-Info "Backing up existing key..."
        $BackupName = "id_ed25519_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Move-Item $KeyFile "$SshDir\$BackupName" -Force
        if (Test-Path $PubKeyFile) {
            Move-Item $PubKeyFile "$SshDir\$BackupName.pub" -Force
        }
        Write-Success "Backup created: $BackupName"

        # Generate new key
        Write-Info "Generating new SSH key..."
        & ssh-keygen -t ed25519 -C $Email -f $KeyFile -N '""'
        Write-Success "New SSH key generated"
    }
} else {
    # Generate new key
    Write-Info "Generating SSH key..."
    & ssh-keygen -t ed25519 -C $Email -f $KeyFile -N '""'

    if (Test-Path $KeyFile) {
        Write-Success "SSH key generated successfully"
    } else {
        Write-Error "Failed to generate SSH key"
        exit 1
    }
}

# ============================================================================
# STEP 4: Configure SSH
# ============================================================================
Write-Step "STEP 4: Configuring SSH..."

$SshConfig = "$SshDir\config"
$ConfigContent = @"
Host github.com
    HostName github.com
    User git
    IdentityFile $KeyFile
    IdentitiesOnly yes
"@

if (Test-Path $SshConfig) {
    $ExistingConfig = Get-Content $SshConfig -Raw
    if ($ExistingConfig -notmatch "github.com") {
        Write-Info "Adding GitHub configuration to SSH config..."
        Add-Content -Path $SshConfig -Value "`n$ConfigContent"
        Write-Success "SSH config updated"
    } else {
        Write-Success "GitHub already configured in SSH config"
    }
} else {
    Write-Info "Creating SSH config file..."
    Set-Content -Path $SshConfig -Value $ConfigContent
    Write-Success "SSH config created"
}

# ============================================================================
# STEP 5: Display Public Key
# ============================================================================
Write-Step "STEP 5: Adding SSH Key to GitHub..."

if (Test-Path $PubKeyFile) {
    $PublicKey = Get-Content $PubKeyFile -Raw

    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "YOUR PUBLIC SSH KEY (copy this):" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host $PublicKey -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""

    # Copy to clipboard if possible
    try {
        Set-Clipboard -Value $PublicKey
        Write-Success "Public key copied to clipboard!"
    } catch {
        Write-Warning "Could not copy to clipboard automatically"
    }

    Write-Info "Please add this SSH key to your GitHub account:"
    Write-Host "  1. Go to: https://github.com/settings/ssh/new" -ForegroundColor White
    Write-Host "  2. Title: 'Cruise_Logs - $env:COMPUTERNAME'" -ForegroundColor White
    Write-Host "  3. Paste the key above into the 'Key' field" -ForegroundColor White
    Write-Host "  4. Click 'Add SSH key'" -ForegroundColor White
    Write-Host ""

    Read-Host "Press Enter after adding the key to GitHub"
} else {
    Write-Error "Public key file not found!"
    exit 1
}

# ============================================================================
# STEP 6: Test SSH Connection
# ============================================================================
Write-Step "STEP 6: Testing GitHub Connection..."

Write-Info "Testing SSH connection to GitHub..."
$TestResult = & ssh -T git@github.com 2>&1

if ($TestResult -match "successfully authenticated") {
    Write-Success "SSH connection to GitHub successful!"
} else {
    Write-Warning "SSH test output: $TestResult"
    Write-Error "SSH connection failed!"
    Write-Info "Please verify:"
    Write-Host "  1. You added the SSH key to your GitHub account" -ForegroundColor White
    Write-Host "  2. You have access to NOAA-PMEL/GTMBA-Cruise_Logs repository" -ForegroundColor White
    Write-Host "  3. Your GitHub account email matches: $Email" -ForegroundColor White
    exit 1
}

# ============================================================================
# STEP 7: Switch Repository to SSH
# ============================================================================
Write-Step "STEP 7: Switching Repository to SSH..."

if (-not (Test-Path $InstallPath)) {
    Write-Error "Install path not found: $InstallPath"
    Write-Info "Please run this script from the correct directory"
    exit 1
}

Push-Location $InstallPath

$CurrentRemote = & git remote get-url origin 2>$null
Write-Info "Current remote: $CurrentRemote"

if ($CurrentRemote -match "^https://") {
    Write-Info "Switching from HTTPS to SSH..."
    & git remote set-url origin git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git

    $NewRemote = & git remote get-url origin
    if ($NewRemote -match "^git@github.com") {
        Write-Success "Repository switched to SSH"
        Write-Info "New remote: $NewRemote"
    } else {
        Write-Error "Failed to switch remote"
    }
} elseif ($CurrentRemote -match "^git@github.com") {
    Write-Success "Repository already using SSH"
} else {
    Write-Warning "Unexpected remote format: $CurrentRemote"
}

Pop-Location

# ============================================================================
# STEP 8: Test Push Access
# ============================================================================
Write-Step "STEP 8: Testing Push Access..."

Push-Location $InstallPath

Write-Info "Testing git push (dry-run)..."
$PushTest = & git push --dry-run origin main 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Success "Push access confirmed!"
} else {
    Write-Warning "Push test output: $PushTest"
    Write-Error "You may not have write access to the repository"
    Write-Info "Please contact the repository administrator"
}

Pop-Location

# ============================================================================
# COMPLETION
# ============================================================================
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  GitHub SSH Setup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Summary:" -ForegroundColor Green
Write-Host "  SSH Key: $KeyFile" -ForegroundColor White
Write-Host "  Email: $Email" -ForegroundColor White
Write-Host "  Remote: git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git" -ForegroundColor White
Write-Host ""

Write-Host "You can now push database updates with:" -ForegroundColor Yellow
Write-Host "  cd $InstallPath" -ForegroundColor White
Write-Host "  git add Cruise_Logs.db" -ForegroundColor White
Write-Host "  git commit -m 'Updated cruise logs'" -ForegroundColor White
Write-Host "  git push origin main" -ForegroundColor White
Write-Host ""

Write-Host "For help, see: $InstallPath\windows\FIELD_DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
