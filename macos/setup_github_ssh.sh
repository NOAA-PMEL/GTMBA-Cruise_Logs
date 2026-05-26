#!/bin/bash
# Setup GitHub SSH for Cruise_Logs Repository
# This script converts the repository from HTTPS to SSH authentication
#
# USAGE:
#   bash setup_github_ssh.sh
#   or: chmod +x setup_github_ssh.sh && ./setup_github_ssh.sh

# ============================================================================
# COLOR OUTPUT FUNCTIONS
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

header() {
    echo ""
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo ""
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

header "GitHub SSH Setup for Cruise_Logs"

info "This script will:"
echo "  1. Check for existing SSH keys"
echo "  2. Help generate SSH keys if needed"
echo "  3. Test SSH connection to GitHub"
echo "  4. Convert repository from HTTPS to SSH"
echo ""

read -p "Continue? (yes/no): " response
if [ "$response" != "yes" ]; then
    info "Setup cancelled"
    exit 0
fi

echo ""

# ============================================================================
# STEP 1: Check for Git
# ============================================================================
info "STEP 1: Checking Git installation..."
echo ""

if command -v git >/dev/null 2>&1; then
    git_version=$(git --version)
    success "Git is installed: $git_version"
else
    error "Git is not installed!"
    info "Install with: brew install git"
    exit 1
fi

echo ""

# ============================================================================
# STEP 2: Check for existing SSH keys
# ============================================================================
info "STEP 2: Checking for SSH keys..."
echo ""

ssh_dir="$HOME/.ssh"
key_found=false
key_file=""

if [ -d "$ssh_dir" ]; then
    for key in "id_ed25519" "id_rsa" "id_ecdsa"; do
        if [ -f "$ssh_dir/$key" ]; then
            success "Found SSH key: $key"
            key_file="$ssh_dir/$key"
            key_found=true
            break
        fi
    done
fi

if [ "$key_found" = false ]; then
    warn "No SSH keys found in $ssh_dir"
    echo ""
    info "Would you like to generate an SSH key now?"
    echo "This will create a new ed25519 key (recommended)"
    echo ""

    read -p "Generate SSH key? (yes/no): " response

    if [ "$response" = "yes" ]; then
        echo ""
        read -p "Enter your GitHub email address: " email

        info "Generating SSH key..."
        ssh-keygen -t ed25519 -C "$email" -f "$ssh_dir/id_ed25519"

        if [ $? -eq 0 ]; then
            success "SSH key generated successfully"
            key_file="$ssh_dir/id_ed25519"
            key_found=true

            echo ""
            info "Starting ssh-agent..."
            eval "$(ssh-agent -s)"

            info "Adding key to ssh-agent..."
            ssh-add "$key_file"

            echo ""
            success "Key added to ssh-agent"
        else
            error "Failed to generate SSH key"
            exit 1
        fi
    else
        error "SSH key is required to continue"
        info "Please generate an SSH key manually:"
        echo "  ssh-keygen -t ed25519 -C \"your_email@example.com\""
        exit 1
    fi
fi

echo ""

# ============================================================================
# STEP 3: Display public key and instructions
# ============================================================================
info "STEP 3: Add SSH key to GitHub..."
echo ""

pub_key_file="$ssh_dir/id_ed25519.pub"
if [ ! -f "$pub_key_file" ]; then
    pub_key_file="$ssh_dir/id_rsa.pub"
fi

if [ -f "$pub_key_file" ]; then
    info "Your public SSH key:"
    echo ""
    echo "─────────────────────────────────────────────────"
    cat "$pub_key_file"
    echo "─────────────────────────────────────────────────"
    echo ""

    info "Copying public key to clipboard..."
    if command -v pbcopy >/dev/null 2>&1; then
        cat "$pub_key_file" | pbcopy
        success "Public key copied to clipboard!"
    else
        warn "Could not copy to clipboard (pbcopy not found)"
    fi

    echo ""
    info "To add this key to GitHub:"
    echo "  1. Go to: https://github.com/settings/keys"
    echo "  2. Click 'New SSH key'"
    echo "  3. Give it a title (e.g., 'Work Mac')"
    echo "  4. Paste the key (already in your clipboard)"
    echo "  5. Click 'Add SSH key'"
    echo ""

    read -p "Have you added the key to GitHub? (yes/no): " response
    if [ "$response" != "yes" ]; then
        warn "Please add the key to GitHub and run this script again"
        exit 0
    fi
fi

echo ""

# ============================================================================
# STEP 4: Test SSH connection
# ============================================================================
info "STEP 4: Testing SSH connection to GitHub..."
echo ""

info "Testing connection..."
ssh_test=$(ssh -T git@github.com 2>&1)

if echo "$ssh_test" | grep -q "successfully authenticated"; then
    success "SSH connection to GitHub successful!"
    echo "  $ssh_test"
else
    error "SSH connection failed"
    echo "  $ssh_test"
    echo ""
    info "Common issues:"
    echo "  - SSH key not added to GitHub account"
    echo "  - ssh-agent not running"
    echo "  - Firewall blocking SSH (port 22)"
    echo ""
    read -p "Continue anyway? (yes/no): " response
    if [ "$response" != "yes" ]; then
        exit 1
    fi
fi

echo ""

# ============================================================================
# STEP 5: Find repository location
# ============================================================================
info "STEP 5: Locating repository..."
echo ""

repo_path=""
possible_paths=(
    "$HOME/NOAA-GitHub/GTMBA-Cruise_Logs"
    "$HOME/Documents/Cruise_Logs"
    "$HOME/Cruise_Logs"
    "$(pwd)"
)

for path in "${possible_paths[@]}"; do
    if [ -d "$path/.git" ]; then
        repo_path="$path"
        success "Found repository at: $repo_path"
        break
    fi
done

if [ -z "$repo_path" ]; then
    warn "Could not auto-detect repository location"
    echo ""
    read -p "Enter the full path to your Cruise_Logs repository: " custom_path

    if [ -d "$custom_path/.git" ]; then
        repo_path="$custom_path"
        success "Repository found"
    else
        error "Not a valid Git repository: $custom_path"
        exit 1
    fi
fi

echo ""

# ============================================================================
# STEP 6: Check current remote
# ============================================================================
info "STEP 6: Checking current Git remote..."
echo ""

cd "$repo_path" || exit 1

current_remote=$(git remote get-url origin 2>/dev/null)

if [ -n "$current_remote" ]; then
    info "Current remote URL:"
    echo "  $current_remote"
    echo ""

    if echo "$current_remote" | grep -q "^git@github.com:"; then
        success "Repository is already using SSH!"
        echo ""
        info "No changes needed."
        exit 0
    fi

    if echo "$current_remote" | grep -q "https://github.com/"; then
        info "Repository is using HTTPS - will convert to SSH"
    else
        warn "Remote URL format not recognized"
        info "Will set to: git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git"
    fi
else
    warn "No remote 'origin' found"
    info "Will add: git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git"
fi

echo ""

# ============================================================================
# STEP 7: Convert to SSH
# ============================================================================
info "STEP 7: Converting repository to SSH..."
echo ""

ssh_url="git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git"

info "Setting remote URL to: $ssh_url"
git remote set-url origin "$ssh_url"

if [ $? -eq 0 ]; then
    success "Remote URL updated successfully"

    # Verify the change
    new_remote=$(git remote get-url origin)
    echo ""
    info "New remote URL:"
    echo -e "  ${GREEN}$new_remote${NC}"
else
    error "Failed to update remote URL"
    exit 1
fi

echo ""

# ============================================================================
# STEP 8: Test Git operations
# ============================================================================
info "STEP 8: Testing Git operations..."
echo ""

info "Fetching from remote..."
if git fetch origin >/dev/null 2>&1; then
    success "Git fetch successful - SSH is working!"
else
    error "Git fetch failed"
    info "You may need to troubleshoot SSH connection"
fi

echo ""

# ============================================================================
# COMPLETION
# ============================================================================
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  GitHub SSH Setup Complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

echo -e "${GREEN}Summary:${NC}"
echo "  Repository:  $repo_path"
echo "  Remote URL:  $ssh_url"
echo "  SSH Status:  Configured"
echo ""

echo -e "${YELLOW}You can now:${NC}"
echo "  • git pull - Pull latest changes"
echo "  • git push - Push your changes"
echo "  • git fetch - Fetch remote updates"
echo ""

echo -e "${CYAN}All Git operations will now use SSH authentication.${NC}"
echo ""
