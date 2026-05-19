# Setup GitHub SSH for Cruise_Logs Repository
# This script converts the repository from HTTPS to SSH authentication
#
# USAGE:
#   powershell -ExecutionPolicy Bypass -File setup_github_ssh.ps1

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

Write-Header "GitHub SSH Setup for Cruise_Logs"

Write-Info "This script will:"
Write-Host "  1. Check for existing SSH keys"
Write-Host "  2. Help generate SSH keys if needed"
Write-Host "  3. Test SSH connection to GitHub"
Write-Host "  4. Convert repository from HTTPS to SSH"
Write-Host ""

$Response = Read-Host "Continue? (yes/no)"
if ($Response -ne "yes") {
    Write-Info "Setup cancelled"
    exit 0
}

Write-Host ""

# ============================================================================
# STEP 1: Check for Git
# ============================================================================
Write-Info "STEP 1: Checking Git installation..."
Write-Host ""

try {
    $GitVersion = & git --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Git is installed: $GitVersion"
    }
} catch {
    Write-Error "Git is not installed!"
    Write-Info "Please install Git from: https://git-scm.com/download/win"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# ============================================================================
# STEP 2: Check for existing SSH keys
# ============================================================================
Write-Info "STEP 2: Checking for SSH keys..."
Write-Host ""

$SshDir = "$env:USERPROFILE\.ssh"
$KeyFound = $false
$KeyFiles = @()

if (Test-Path $SshDir) {
    $PossibleKeys = @("id_ed25519", "id_rsa", "id_ecdsa")
    foreach ($key in $PossibleKeys) {
        if (Test-Path "$SshDir\$key") {
            Write-Success "Found SSH key: $key"
            $KeyFiles += "$SshDir\$key"
            $KeyFound = $true
        }
    }
}

if (-not $KeyFound) {
    Write-Warning "No SSH keys found in $SshDir"
    Write-Host ""
    Write-Info "Would you like to generate an SSH key now?"
    Write-Host "This will create a new ed25519 key (recommended)"
    Write-Host ""

    $Response = Read-Host "Generate SSH key? (yes/no)"

    if ($Response -eq "yes") {
        Write-Host ""
        $Email = Read-Host "Enter your GitHub email address"

        Write-Info "Generating SSH key..."
        & ssh-keygen -t ed25519 -C "$Email" -f "$SshDir\id_ed25519"

        if ($LASTEXITCODE -eq 0) {
            Write-Success "SSH key generated successfully"
            $KeyFiles += "$SshDir\id_ed25519"
            $KeyFound = $true

            Write-Host ""
            Write-Info "Starting ssh-agent..."

            # Start ssh-agent
            $SshAgent = Get-Service ssh-agent -ErrorAction SilentlyContinue
            if ($SshAgent) {
                if ($SshAgent.Status -ne "Running") {
                    Start-Service ssh-agent
                }
            }

            # Add key to ssh-agent
            Write-Info "Adding key to ssh-agent..."
            & ssh-add "$SshDir\id_ed25519"

            Write-Host ""
            Write-Success "Key added to ssh-agent"
        } else {
            Write-Error "Failed to generate SSH key"
            exit 1
        }
    } else {
        Write-Error "SSH key is required to continue"
        Write-Info "Please generate an SSH key manually:"
        Write-Host "  ssh-keygen -t ed25519 -C `"your_email@example.com`""
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""

# ============================================================================
# STEP 3: Display public key and instructions
# ============================================================================
Write-Info "STEP 3: Add SSH key to GitHub..."
Write-Host ""

$PublicKeyFile = "$SshDir\id_ed25519.pub"
if (-not (Test-Path $PublicKeyFile)) {
    $PublicKeyFile = "$SshDir\id_rsa.pub"
}

if (Test-Path $PublicKeyFile) {
    Write-Info "Your public SSH key:"
    Write-Host ""
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor Yellow
    Get-Content $PublicKeyFile | Write-Host -ForegroundColor White
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor Yellow
    Write-Host ""

    Write-Info "Copying public key to clipboard..."
    Get-Content $PublicKeyFile | Set-Clipboard
    Write-Success "Public key copied to clipboard!"

    Write-Host ""
    Write-Info "To add this key to GitHub:"
    Write-Host "  1. Go to: https://github.com/settings/keys" -ForegroundColor White
    Write-Host "  2. Click 'New SSH key'" -ForegroundColor White
    Write-Host "  3. Give it a title (e.g., 'Work Laptop')" -ForegroundColor White
    Write-Host "  4. Paste the key (already in your clipboard)" -ForegroundColor White
    Write-Host "  5. Click 'Add SSH key'" -ForegroundColor White
    Write-Host ""

    $Response = Read-Host "Have you added the key to GitHub? (yes/no)"
    if ($Response -ne "yes") {
        Write-Warning "Please add the key to GitHub and run this script again"
        Read-Host "Press Enter to exit"
        exit 0
    }
}

Write-Host ""

# ============================================================================
# STEP 4: Test SSH connection
# ============================================================================
Write-Info "STEP 4: Testing SSH connection to GitHub..."
Write-Host ""

Write-Info "Testing connection..."
$TestResult = & ssh -T git@github.com 2>&1
$SshSuccess = $TestResult -match "successfully authenticated"

if ($SshSuccess) {
    Write-Success "SSH connection to GitHub successful!"
    Write-Host "  $TestResult" -ForegroundColor White
} else {
    Write-Error "SSH connection failed"
    Write-Host "  $TestResult" -ForegroundColor Red
    Write-Host ""
    Write-Info "Common issues:"
    Write-Host "  - SSH key not added to GitHub account"
    Write-Host "  - ssh-agent not running"
    Write-Host "  - Firewall blocking SSH (port 22)"
    Write-Host ""
    $Response = Read-Host "Continue anyway? (yes/no)"
    if ($Response -ne "yes") {
        exit 1
    }
}

Write-Host ""

# ============================================================================
# STEP 5: Find repository location
# ============================================================================
Write-Info "STEP 5: Locating repository..."
Write-Host ""

$RepoPath = $null
$PossiblePaths = @(
    "C:\Cruise_Logs",
    "$env:USERPROFILE\Documents\Cruise_Logs",
    "$env:USERPROFILE\Cruise_Logs",
    "$env:USERPROFILE\Github\GTMBA-Cruise_Logs",
    (Get-Location).Path
)

foreach ($path in $PossiblePaths) {
    if (Test-Path "$path\.git") {
        $RepoPath = $path
        Write-Success "Found repository at: $RepoPath"
        break
    }
}

if (-not $RepoPath) {
    Write-Warning "Could not auto-detect repository location"
    Write-Host ""
    $CustomPath = Read-Host "Enter the full path to your Cruise_Logs repository"

    if (Test-Path "$CustomPath\.git") {
        $RepoPath = $CustomPath
        Write-Success "Repository found"
    } else {
        Write-Error "Not a valid Git repository: $CustomPath"
        exit 1
    }
}

Write-Host ""

# ============================================================================
# STEP 6: Check current remote
# ============================================================================
Write-Info "STEP 6: Checking current Git remote..."
Write-Host ""

Push-Location $RepoPath

$CurrentRemote = & git remote get-url origin 2>$null

if ($CurrentRemote) {
    Write-Info "Current remote URL:"
    Write-Host "  $CurrentRemote" -ForegroundColor White
    Write-Host ""

    if ($CurrentRemote -match "^git@github.com:") {
        Write-Success "Repository is already using SSH!"
        Write-Host ""
        Write-Info "No changes needed."
        Pop-Location
        Read-Host "Press Enter to exit"
        exit 0
    }

    if ($CurrentRemote -match "https://github.com/") {
        Write-Info "Repository is using HTTPS - will convert to SSH"
    } else {
        Write-Warning "Remote URL format not recognized"
        Write-Info "Will set to: git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git"
    }
} else {
    Write-Warning "No remote 'origin' found"
    Write-Info "Will add: git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git"
}

Write-Host ""

# ============================================================================
# STEP 7: Convert to SSH
# ============================================================================
Write-Info "STEP 7: Converting repository to SSH..."
Write-Host ""

$SshUrl = "git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git"

Write-Info "Setting remote URL to: $SshUrl"
& git remote set-url origin $SshUrl

if ($LASTEXITCODE -eq 0) {
    Write-Success "Remote URL updated successfully"

    # Verify the change
    $NewRemote = & git remote get-url origin
    Write-Host ""
    Write-Info "New remote URL:"
    Write-Host "  $NewRemote" -ForegroundColor Green
} else {
    Write-Error "Failed to update remote URL"
    Pop-Location
    exit 1
}

Write-Host ""

# ============================================================================
# STEP 8: Test Git operations
# ============================================================================
Write-Info "STEP 8: Testing Git operations..."
Write-Host ""

Write-Info "Fetching from remote..."
& git fetch origin 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Success "Git fetch successful - SSH is working!"
} else {
    Write-Error "Git fetch failed"
    Write-Info "You may need to troubleshoot SSH connection"
}

Pop-Location
Write-Host ""

# ============================================================================
# COMPLETION
# ============================================================================
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  GitHub SSH Setup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Summary:" -ForegroundColor Green
Write-Host "  Repository:  $RepoPath" -ForegroundColor White
Write-Host "  Remote URL:  $SshUrl" -ForegroundColor White
Write-Host "  SSH Status:  Configured" -ForegroundColor White
Write-Host ""

Write-Host "You can now:" -ForegroundColor Yellow
Write-Host "  • git pull - Pull latest changes" -ForegroundColor White
Write-Host "  • git push - Push your changes" -ForegroundColor White
Write-Host "  • git fetch - Fetch remote updates" -ForegroundColor White
Write-Host ""

Write-Host "All Git operations will now use SSH authentication." -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to exit"
