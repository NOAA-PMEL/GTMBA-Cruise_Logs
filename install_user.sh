#!/bin/bash
# Cruise_Logs User Installation Script
# Shell script for installation in user space (no admin/sudo required)
#
# USAGE:
#   bash install_user.sh
#   or
#   ./install_user.sh  (after: chmod +x install_user.sh)
#
# This will install Cruise Logs in your home folder at:
#   ~/Cruise_Logs

# Default installation path
INSTALL_PATH="${HOME}/Cruise_Logs"

# Detect OS
OS_TYPE="$(uname -s)"
case "${OS_TYPE}" in
    Linux*)     PLATFORM="Linux";;
    Darwin*)    PLATFORM="macOS";;
    *)          PLATFORM="Unknown";;
esac

# ============================================================================
# COLOR OUTPUT FUNCTIONS
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

# ============================================================================
# MAIN SCRIPT
# ============================================================================

print_header "Cruise Logs User Installer for ${PLATFORM}"

print_info "This installer will set up Cruise Logs in your user directory"
print_info "Installation directory: ${INSTALL_PATH}"
print_info ""
print_info "No administrator (sudo) privileges required!"
echo ""
read -p "Press Enter to continue..."

# ============================================================================
# STEP 1: Check for Conda
# ============================================================================
print_info "STEP 1: Checking for Anaconda/Miniconda..."
echo ""

CONDA_PATH=""
CONDA_CMD=""

# Check if conda is in PATH
if command -v conda &> /dev/null; then
    CONDA_CMD="conda"
    CONDA_PATH=$(conda info --base 2>/dev/null)
    if [ -n "$CONDA_PATH" ]; then
        print_success "Found Conda in PATH: ${CONDA_PATH}"
    fi
else
    # Check common installation locations
    POSSIBLE_PATHS=(
        "${HOME}/anaconda3"
        "${HOME}/miniconda3"
        "${HOME}/opt/anaconda3"
        "${HOME}/opt/miniconda3"
        "/opt/anaconda3"
        "/opt/miniconda3"
        "/usr/local/anaconda3"
        "/usr/local/miniconda3"
    )

    for path in "${POSSIBLE_PATHS[@]}"; do
        if [ -f "${path}/bin/conda" ]; then
            CONDA_PATH="${path}"
            CONDA_CMD="${path}/bin/conda"
            print_success "Found Conda at: ${CONDA_PATH}"
            break
        fi
    done
fi

if [ -z "$CONDA_PATH" ]; then
    print_error "Anaconda/Miniconda not found!"
    echo ""
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Please install Anaconda or Miniconda:${NC}"
    echo ""
    if [ "$PLATFORM" = "macOS" ]; then
        echo "  Option 1 - Anaconda (full package):"
        echo "    https://www.anaconda.com/download/"
        echo ""
        echo "  Option 2 - Miniconda (lightweight):"
        echo "    https://docs.conda.io/en/latest/miniconda.html"
        echo ""
        echo "  Option 3 - Using Homebrew:"
        echo "    brew install --cask anaconda"
        echo "    or"
        echo "    brew install --cask miniconda"
    else
        echo "  Option 1 - Anaconda (full package):"
        echo "    https://www.anaconda.com/download/"
        echo ""
        echo "  Option 2 - Miniconda (lightweight):"
        echo "    https://docs.conda.io/en/latest/miniconda.html"
        echo ""
        echo "  Quick install (Miniconda):"
        echo "    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
        echo "    bash Miniconda3-latest-Linux-x86_64.sh"
    fi
    echo -e "${YELLOW}========================================${NC}"
    echo ""
    echo "After installing, close and reopen your terminal, then run this script again."
    exit 1
fi

echo ""

# ============================================================================
# STEP 2: Check for Git
# ============================================================================
print_info "STEP 2: Checking for Git..."
echo ""

if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    print_success "Git is installed: ${GIT_VERSION}"
else
    print_error "Git is not installed!"
    echo ""
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}Please install Git:${NC}"
    echo ""
    if [ "$PLATFORM" = "macOS" ]; then
        echo "  Option 1 - Using Xcode Command Line Tools:"
        echo "    xcode-select --install"
        echo ""
        echo "  Option 2 - Using Homebrew:"
        echo "    brew install git"
        echo ""
        echo "  Option 3 - Download installer:"
        echo "    https://git-scm.com/download/mac"
    else
        echo "  Ubuntu/Debian:"
        echo "    sudo apt-get update"
        echo "    sudo apt-get install git"
        echo ""
        echo "  Fedora/RHEL/CentOS:"
        echo "    sudo dnf install git"
        echo "    or"
        echo "    sudo yum install git"
        echo ""
        echo "  Other distributions:"
        echo "    https://git-scm.com/download/linux"
    fi
    echo -e "${YELLOW}========================================${NC}"
    echo ""
    exit 1
fi

echo ""

# ============================================================================
# STEP 3: Clone Repository
# ============================================================================
print_info "STEP 3: Setting up Cruise Logs files..."
echo ""

if [ -d "$INSTALL_PATH" ]; then
    print_warning "Cruise Logs is already installed at: ${INSTALL_PATH}"
    echo ""
    read -p "Do you want to reinstall? This will update to the latest version (yes/no): " RESPONSE

    if [ "$RESPONSE" = "yes" ]; then
        print_info "Removing old installation..."
        if rm -rf "$INSTALL_PATH"; then
            print_success "Old installation removed"
        else
            print_error "Could not remove old installation. Please check permissions."
            exit 1
        fi
    else
        print_info "Using existing installation"
        echo ""
        print_warning "Skipping to environment setup..."
        echo ""
    fi
fi

if [ ! -d "$INSTALL_PATH" ]; then
    print_info "Downloading Cruise Logs from GitHub..."
    print_info "This may take a few minutes depending on your internet connection..."
    echo ""

    # Configure Git for proper line ending handling
    print_info "Configuring Git..."
    git config --global core.autocrlf false 2>&1 > /dev/null
    git config --global core.eol lf 2>&1 > /dev/null

    if git clone https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs.git "$INSTALL_PATH"; then
        print_success "Files downloaded successfully"
    else
        print_error "Failed to download repository"
        print_error "Please check your internet connection and try again"
        exit 1
    fi
fi

echo ""

# ============================================================================
# STEP 4: Create Conda Environment
# ============================================================================
print_info "STEP 4: Creating Python Environment..."
echo ""

# Initialize conda for this script
if [ -n "$CONDA_PATH" ]; then
    source "${CONDA_PATH}/etc/profile.d/conda.sh" 2>/dev/null || true
fi

# Check if environment already exists
if $CONDA_CMD env list | grep -q "^cruise_logs "; then
    print_info "Environment 'cruise_logs' already exists"
    read -p "Recreate environment? This ensures you have the latest packages (yes/no): " RESPONSE

    if [ "$RESPONSE" = "yes" ]; then
        print_info "Removing old environment..."
        $CONDA_CMD remove -n cruise_logs --all -y > /dev/null 2>&1
        print_success "Old environment removed"
        ENV_EXISTS="no"
    else
        ENV_EXISTS="yes"
    fi
else
    ENV_EXISTS="no"
fi

if [ "$ENV_EXISTS" = "no" ]; then
    print_info "Creating 'cruise_logs' environment with Python 3.11..."
    print_info "This may take a few minutes..."
    echo ""

    if $CONDA_CMD create -n cruise_logs python=3.11 -y; then
        print_success "Environment created successfully"
    else
        print_error "Failed to create environment"
        print_error "There may be an issue with your Conda installation"
        exit 1
    fi
fi

echo ""

# ============================================================================
# STEP 5: Install Python Packages
# ============================================================================
print_info "STEP 5: Installing Required Packages..."
echo ""

# Activate the environment
source "${CONDA_PATH}/etc/profile.d/conda.sh"
conda activate cruise_logs

if [ -f "${INSTALL_PATH}/requirements.txt" ]; then
    print_info "Installing packages (streamlit, pandas, etc.)..."
    print_info "This may take several minutes on first installation..."
    echo ""

    if pip install -r "${INSTALL_PATH}/requirements.txt"; then
        print_success "All packages installed successfully"
    else
        print_error "Failed to install some packages"
        print_warning "You may still be able to use Cruise Logs, but some features might not work"
        echo ""
        read -p "Press Enter to continue anyway..."
    fi
else
    print_error "requirements.txt not found in ${INSTALL_PATH}"
    print_error "The installation may be incomplete"
    exit 1
fi

# Deactivate the environment
conda deactivate

echo ""

# ============================================================================
# STEP 6: Verify Installation
# ============================================================================
print_info "STEP 6: Verifying Installation..."
echo ""

cd "$INSTALL_PATH"

# Check database
if [ -f "Cruise_Logs.db" ]; then
    DB_SIZE=$(du -m "Cruise_Logs.db" | cut -f1)
    if [ "$DB_SIZE" -gt 1 ]; then
        print_success "Database file OK (${DB_SIZE} MB)"
    else
        print_warning "Database file is small (may be empty or corrupted)"
    fi
else
    print_warning "Database file not found - will be created on first use"
fi

# Check required files
REQUIRED_FILES=("cruise_form.py" "launcher.py" "requirements.txt")
ALL_FILES_FOUND=true

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_success "Found: ${file}"
    else
        print_error "Missing: ${file}"
        ALL_FILES_FOUND=false
    fi
done

if [ "$ALL_FILES_FOUND" = false ]; then
    print_error "Some required files are missing"
    print_error "The installation may be incomplete"
    echo ""
    exit 1
fi

cd - > /dev/null
echo ""

# ============================================================================
# STEP 7: Create Launch Scripts
# ============================================================================
print_info "STEP 7: Creating Launch Scripts..."
echo ""

print_info "Launch scripts will make it easy to start Cruise Logs"
read -p "Create launch scripts in installation directory? (yes/no): " RESPONSE

if [ "$RESPONSE" = "yes" ]; then
    # Create launcher script
    LAUNCHER_SCRIPT="${INSTALL_PATH}/start_cruise_logs.sh"
    
    cat > "$LAUNCHER_SCRIPT" << 'LAUNCHER_EOF'
#!/bin/bash
# Cruise Logs Launcher Script

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Find conda
CONDA_PATH=""
if command -v conda &> /dev/null; then
    CONDA_PATH=$(conda info --base 2>/dev/null)
else
    POSSIBLE_PATHS=(
        "${HOME}/anaconda3"
        "${HOME}/miniconda3"
        "${HOME}/opt/anaconda3"
        "${HOME}/opt/miniconda3"
        "/opt/anaconda3"
        "/opt/miniconda3"
    )
    
    for path in "${POSSIBLE_PATHS[@]}"; do
        if [ -f "${path}/bin/conda" ]; then
            CONDA_PATH="${path}"
            break
        fi
    done
fi

if [ -z "$CONDA_PATH" ]; then
    echo "ERROR: Could not find Conda installation"
    exit 1
fi

# Initialize conda
source "${CONDA_PATH}/etc/profile.d/conda.sh"

# Activate environment
conda activate cruise_logs

# Change to script directory
cd "$SCRIPT_DIR"

# Launch the application
echo "Starting Cruise Logs..."
echo "The application will open in your web browser."
echo "Press Ctrl+C to stop the application."
echo ""

streamlit run cruise_form.py
LAUNCHER_EOF

    chmod +x "$LAUNCHER_SCRIPT"
    print_success "Created: start_cruise_logs.sh"
    
    # Create launcher with GUI option (using python launcher.py)
    GUI_LAUNCHER="${INSTALL_PATH}/start_cruise_logs_gui.sh"
    
    cat > "$GUI_LAUNCHER" << 'GUI_EOF'
#!/bin/bash
# Cruise Logs GUI Launcher Script

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Find conda
CONDA_PATH=""
if command -v conda &> /dev/null; then
    CONDA_PATH=$(conda info --base 2>/dev/null)
else
    POSSIBLE_PATHS=(
        "${HOME}/anaconda3"
        "${HOME}/miniconda3"
        "${HOME}/opt/anaconda3"
        "${HOME}/opt/miniconda3"
        "/opt/anaconda3"
        "/opt/miniconda3"
    )
    
    for path in "${POSSIBLE_PATHS[@]}"; do
        if [ -f "${path}/bin/conda" ]; then
            CONDA_PATH="${path}"
            break
        fi
    done
fi

if [ -z "$CONDA_PATH" ]; then
    echo "ERROR: Could not find Conda installation"
    exit 1
fi

# Initialize conda
source "${CONDA_PATH}/etc/profile.d/conda.sh"

# Activate environment
conda activate cruise_logs

# Change to script directory
cd "$SCRIPT_DIR"

# Launch the GUI launcher
python launcher.py
GUI_EOF

    chmod +x "$GUI_LAUNCHER"
    print_success "Created: start_cruise_logs_gui.sh"
    
    echo ""
    print_success "Launch scripts created successfully!"
    
else
    print_info "Skipping launch script creation"
fi

echo ""

# ============================================================================
# COMPLETION
# ============================================================================
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

echo -e "${GREEN}Summary:${NC}"
echo "  Platform:     ${PLATFORM}"
echo "  Install Path: ${INSTALL_PATH}"
echo "  Environment:  cruise_logs (Python 3.11)"
echo "  User:         ${USER}"
echo ""

echo -e "${YELLOW}How to Launch Cruise Logs:${NC}"
echo ""

if [ "$RESPONSE" = "yes" ]; then
    echo -e "${CYAN}  EASY WAY (using launch scripts):${NC}"
    echo "    cd ${INSTALL_PATH}"
    echo "    ./start_cruise_logs.sh"
    echo ""
    echo "  Or with GUI launcher:"
    echo "    ./start_cruise_logs_gui.sh"
    echo ""
fi

echo -e "${CYAN}  MANUAL WAY:${NC}"
echo "    1. Open a terminal"
echo "    2. Run these commands:"
echo -e "       ${GREEN}conda activate cruise_logs${NC}"
echo -e "       ${GREEN}cd ${INSTALL_PATH}${NC}"
echo -e "       ${GREEN}streamlit run cruise_form.py${NC}"
echo ""

if [ "$PLATFORM" = "macOS" ]; then
    echo -e "${CYAN}  OPTIONAL - Create Application Alias:${NC}"
    echo "    You can drag the launch script to your Dock for quick access"
    echo ""
fi

# Check for documentation
if [ -f "${INSTALL_PATH}/README.md" ]; then
    echo -e "${CYAN}For more information, see: ${INSTALL_PATH}/README.md${NC}"
fi

echo ""
echo "Installation directory: ${INSTALL_PATH}"
echo ""

read -p "Press Enter to exit..."
