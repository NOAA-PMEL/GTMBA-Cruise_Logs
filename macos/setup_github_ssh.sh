#!/bin/bash
# GitHub SSH Setup Script for Cruise_Logs (macOS/Linux)
# Automates SSH key generation and GitHub configuration
#
# USAGE:
#   bash setup_github_ssh.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default install path
INSTALL_PATH="${HOME}/Cruise_Logs"

# Functions
print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo ""
}

print_step() {
    echo ""
    echo -e "${YELLOW}>>> $1${NC}"
    echo ""
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

print_header "GitHub SSH Setup for Cruise_Logs"

print_info "This script will:"
echo "  1. Generate SSH keys for GitHub (if needed)"
echo "  2. Configure Git to use SSH"
echo "  3. Switch the repository to use SSH"
echo "  4. Test the connection"
echo ""

# ============================================================================
# STEP 1: Check for Git
# ============================================================================
print_step "STEP 1: Checking for Git..."

if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    print_success "Git is installed: $GIT_VERSION"
else
    print_error "Git is not installed!"
    print_info "Install with: brew install git"
    exit 1
fi

# ============================================================================
# STEP 2: Get User Email
# ============================================================================
print_step "STEP 2: Getting User Information..."

if [ -z "$1" ]; then
    read -p "Enter your GitHub email address: " EMAIL
else
    EMAIL="$1"
fi

if [[ ! "$EMAIL" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
    print_error "Invalid email address!"
    exit 1
fi

print_success "Email: $EMAIL"

# Configure Git
git config --global user.email "$EMAIL"
GIT_NAME=$(git config --global user.name)
if [ -z "$GIT_NAME" ]; then
    read -p "Enter your name (for Git commits): " GIT_NAME
    git config --global user.name "$GIT_NAME"
fi
print_success "Git configured for: $GIT_NAME <$EMAIL>"

# ============================================================================
# STEP 3: Check/Generate SSH Keys
# ============================================================================
print_step "STEP 3: Setting up SSH Keys..."

SSH_DIR="$HOME/.ssh"
KEY_FILE="$SSH_DIR/id_ed25519"
PUB_KEY_FILE="$KEY_FILE.pub"

# Create .ssh directory if it doesn't exist
if [ ! -d "$SSH_DIR" ]; then
    print_info "Creating .ssh directory..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# Check if key already exists
if [ -f "$KEY_FILE" ]; then
    print_warning "SSH key already exists at: $KEY_FILE"
    read -p "Use existing key? (yes/no): " RESPONSE

    if [ "$RESPONSE" != "yes" ]; then
        print_info "Backing up existing key..."
        BACKUP_NAME="id_ed25519_backup_$(date +%Y%m%d_%H%M%S)"
        mv "$KEY_FILE" "$SSH_DIR/$BACKUP_NAME"
        if [ -f "$PUB_KEY_FILE" ]; then
            mv "$PUB_KEY_FILE" "$SSH_DIR/$BACKUP_NAME.pub"
        fi
        print_success "Backup created: $BACKUP_NAME"

        # Generate new key
        print_info "Generating new SSH key..."
        ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE" -N ""
        print_success "New SSH key generated"
    fi
else
    # Generate new key
    print_info "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE" -N ""

    if [ -f "$KEY_FILE" ]; then
        print_success "SSH key generated successfully"
    else
        print_error "Failed to generate SSH key"
        exit 1
    fi
fi

# Set proper permissions
chmod 600 "$KEY_FILE"
chmod 644 "$PUB_KEY_FILE"

# ============================================================================
# STEP 4: Configure SSH
# ============================================================================
print_step "STEP 4: Configuring SSH..."

SSH_CONFIG="$SSH_DIR/config"
CONFIG_CONTENT="Host github.com
    HostName github.com
    User git
    IdentityFile $KEY_FILE
    IdentitiesOnly yes"

if [ -f "$SSH_CONFIG" ]; then
    if ! grep -q "github.com" "$SSH_CONFIG"; then
        print_info "Adding GitHub configuration to SSH config..."
        echo "" >> "$SSH_CONFIG"
        echo "$CONFIG_CONTENT" >> "$SSH_CONFIG"
        print_success "SSH config updated"
    else
        print_success "GitHub already configured in SSH config"
    fi
else
    print_info "Creating SSH config file..."
    echo "$CONFIG_CONTENT" > "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
    print_success "SSH config created"
fi

# ============================================================================
# STEP 5: Start SSH Agent and Add Key (macOS specific)
# ============================================================================
print_step "STEP 5: Adding Key to SSH Agent..."

# Start ssh-agent if not running
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# Add key to agent
ssh-add "$KEY_FILE" 2>/dev/null
if [ $? -eq 0 ]; then
    print_success "SSH key added to agent"
else
    print_warning "Could not add key to agent (may already be added)"
fi

# macOS: Add to keychain
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_info "Adding key to macOS Keychain..."
    ssh-add --apple-use-keychain "$KEY_FILE" 2>/dev/null
    if [ $? -eq 0 ]; then
        print_success "Key added to macOS Keychain"

        # Update SSH config for keychain
        if ! grep -q "UseKeychain yes" "$SSH_CONFIG"; then
            sed -i '' '/Host github.com/a\
    UseKeychain yes\
    AddKeysToAgent yes
' "$SSH_CONFIG"
        fi
    fi
fi

# ============================================================================
# STEP 6: Display Public Key
# ============================================================================
print_step "STEP 6: Adding SSH Key to GitHub..."

if [ -f "$PUB_KEY_FILE" ]; then
    PUBLIC_KEY=$(cat "$PUB_KEY_FILE")

    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}YOUR PUBLIC SSH KEY (copy this):${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo -e "${YELLOW}$PUBLIC_KEY${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""

    # Copy to clipboard if possible
    if command -v pbcopy &> /dev/null; then
        echo "$PUBLIC_KEY" | pbcopy
        print_success "Public key copied to clipboard!"
    elif command -v xclip &> /dev/null; then
        echo "$PUBLIC_KEY" | xclip -selection clipboard
        print_success "Public key copied to clipboard!"
    else
        print_warning "Could not copy to clipboard automatically"
    fi

    print_info "Please add this SSH key to your GitHub account:"
    echo "  1. Go to: https://github.com/settings/ssh/new"
    echo "  2. Title: 'Cruise_Logs - $(hostname)'"
    echo "  3. Paste the key above into the 'Key' field"
    echo "  4. Click 'Add SSH key'"
    echo ""

    read -p "Press Enter after adding the key to GitHub..."
else
    print_error "Public key file not found!"
    exit 1
fi

# ============================================================================
# STEP 7: Test SSH Connection
# ============================================================================
print_step "STEP 7: Testing GitHub Connection..."

print_info "Testing SSH connection to GitHub..."
TEST_RESULT=$(ssh -T git@github.com 2>&1)

if echo "$TEST_RESULT" | grep -q "successfully authenticated"; then
    print_success "SSH connection to GitHub successful!"
else
    print_warning "SSH test output: $TEST_RESULT"
    print_error "SSH connection failed!"
    print_info "Please verify:"
    echo "  1. You added the SSH key to your GitHub account"
    echo "  2. You have access to NOAA-PMEL/GTMBA-Cruise_Logs repository"
    echo "  3. Your GitHub account email matches: $EMAIL"
    exit 1
fi

# ============================================================================
# STEP 8: Switch Repository to SSH
# ============================================================================
print_step "STEP 8: Switching Repository to SSH..."

if [ ! -d "$INSTALL_PATH" ]; then
    print_error "Install path not found: $INSTALL_PATH"
    print_info "Please run this script from the correct directory"
    exit 1
fi

cd "$INSTALL_PATH"

CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null)
print_info "Current remote: $CURRENT_REMOTE"

if [[ "$CURRENT_REMOTE" =~ ^https:// ]]; then
    print_info "Switching from HTTPS to SSH..."
    git remote set-url origin git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git

    NEW_REMOTE=$(git remote get-url origin)
    if [[ "$NEW_REMOTE" =~ ^git@github.com ]]; then
        print_success "Repository switched to SSH"
        print_info "New remote: $NEW_REMOTE"
    else
        print_error "Failed to switch remote"
    fi
elif [[ "$CURRENT_REMOTE" =~ ^git@github.com ]]; then
    print_success "Repository already using SSH"
else
    print_warning "Unexpected remote format: $CURRENT_REMOTE"
fi

# ============================================================================
# STEP 9: Test Push Access
# ============================================================================
print_step "STEP 9: Testing Push Access..."

print_info "Testing git push (dry-run)..."
PUSH_TEST=$(git push --dry-run origin main 2>&1)

if [ $? -eq 0 ]; then
    print_success "Push access confirmed!"
else
    print_warning "Push test output: $PUSH_TEST"
    print_error "You may not have write access to the repository"
    print_info "Please contact the repository administrator"
fi

# ============================================================================
# COMPLETION
# ============================================================================
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  GitHub SSH Setup Complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

echo -e "${GREEN}Summary:${NC}"
echo "  SSH Key: $KEY_FILE"
echo "  Email: $EMAIL"
echo "  Remote: git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git"
echo ""

echo -e "${YELLOW}You can now push database updates with:${NC}"
echo "  cd $INSTALL_PATH"
echo "  git add Cruise_Logs.db"
echo "  git commit -m 'Updated cruise logs'"
echo "  git push origin main"
echo ""

echo -e "${CYAN}For help, see: $INSTALL_PATH/macos/README.md${NC}"
echo ""
