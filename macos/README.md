# macOS Setup Files

This directory contains macOS-specific documentation and configuration files for setting up Cruise_Logs on macOS systems.

## 📁 Contents

| File | Description |
|------|-------------|
| **SETUP_MACOS.md** | Comprehensive macOS installation guide with Anaconda and troubleshooting |
| **README.md** | This file |

## 🚀 Quick Start for macOS Installation

### 1. Prerequisites
- macOS 10.15 (Catalina) or later
- Xcode Command Line Tools (includes Git)
- Python 3.9+ (Anaconda or venv)

### 2. Installation Steps

```bash
# Install Xcode Command Line Tools (includes Git)
xcode-select --install

# Verify Git installation
git --version

# Clone repository
cd ~/NOAA-GitHub
git clone git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git
cd GTMBA-Cruise_Logs

# Create conda environment
conda create -n cruise_logs python=3.11 -y
conda activate cruise_logs

# Install packages
pip install -r requirements.txt

# Verify setup
python verify_setup.py

# Run application
streamlit run cruise_form.py
```

## 📖 Documentation

### SETUP_MACOS.md
Complete macOS setup guide including:
- Git setup via Xcode Command Line Tools
- Python environment (Anaconda or venv)
- Database configuration
- Terminal aliases and shortcuts
- Database synchronization
- Troubleshooting for macOS-specific issues

## 🎯 Default Configuration

The repository is configured with these default paths for macOS:
- **Installation:** `~/NOAA-GitHub/GTMBA-Cruise_Logs`
- **Database:** `~/NOAA-GitHub/GTMBA-Cruise_Logs/Cruise_Logs.db`

Most Python files already use `os.path.expanduser()` so they should work automatically if you clone to `~/NOAA-GitHub/GTMBA-Cruise_Logs`.

## 🔧 Path Configuration

If you cloned to a different location, you may need to update these files:
- `adcp_dep_form.py` (Line 9) - Update absolute path
- Other files use `os.path.expanduser()` and should work automatically

**Recommended:** Use the cross-platform `config.py` module:
```python
from config import DB_PATH
```

## 💡 macOS-Specific Features

### Terminal Aliases
Add to `~/.zshrc` (or `~/.bash_profile` for older macOS):
```bash
alias cruise-form='cd ~/NOAA-GitHub/GTMBA-Cruise_Logs && conda activate cruise_logs && streamlit run cruise_form.py'
alias cruise-releases='cd ~/NOAA-GitHub/GTMBA-Cruise_Logs && conda activate cruise_logs && streamlit run release_inventory_search.py'
```

### Automator App
Create a clickable app using macOS Automator - see SETUP_MACOS.md for instructions.

### Shell Script Launcher
```bash
#!/bin/bash
cd ~/NOAA-GitHub/GTMBA-Cruise_Logs
conda activate cruise_logs
streamlit run cruise_form.py
```

## ⚙️ Environment Options

### Option A: Anaconda (Recommended)
```bash
conda create -n cruise_logs python=3.11 -y
conda activate cruise_logs
pip install -r requirements.txt
```

### Option B: venv (Built-in)
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 🔍 Quick Verification

```bash
# Navigate to repository
cd ~/NOAA-GitHub/GTMBA-Cruise_Logs

# Activate environment
conda activate cruise_logs

# Run verification
python verify_setup.py
```

This checks:
- Python version (3.9+)
- Required packages (streamlit, pandas, etc.)
- Database file
- Application files
- Git configuration

## 📦 Running Applications

```bash
# Always start by activating environment
conda activate cruise_logs
cd ~/NOAA-GitHub/GTMBA-Cruise_Logs

# Main forms
streamlit run cruise_form.py          # Cruise information
streamlit run dep_form_JSON.py         # Deployment form
streamlit run rec_form_JSON.py         # Recovery form
streamlit run repair_form_JSON.py      # Repair form

# ADCP forms
streamlit run adcp_dep_form.py         # ADCP deployment
streamlit run adcp_rec_form.py         # ADCP recovery

# Search applications
streamlit run release_inventory_search.py  # 569 acoustic releases
streamlit run nylon_inventory_search.py    # 1,723 nylon spools
```

## 🔄 Database Sync

Sync with remote server (requires GitHub authentication):
```bash
python db_sync2.py --status    # Check sync status
python db_sync2.py --pull      # Download from remote
python db_sync2.py --push      # Upload to remote
```

## 🆘 Troubleshooting

### Conda not found
```bash
# Add to ~/.zshrc
export PATH="/usr/local/anaconda3/bin:$PATH"
source ~/.zshrc
```

### Port already in use
```bash
# Streamlit auto-selects next port, or:
lsof -ti:8501 | xargs kill
```

### Python version too old
```bash
# Download and install Python from python.org
# Visit: https://www.python.org/downloads/macos/
# Or install Anaconda which includes Python 3.11
```

See **SETUP_MACOS.md** for comprehensive troubleshooting.

## 📚 Related Files

In parent directory:
- `../README.md` - Main project documentation
- `../requirements.txt` - Python dependencies
- `../config.py` - Cross-platform configuration
- `../verify_setup.py` - Setup verification script
- `../.gitignore` - Git ignore rules

## ✅ Success Criteria

Installation is complete when:
- ✓ Conda environment activates: `conda activate cruise_logs`
- ✓ Verification passes: `python verify_setup.py`
- ✓ Main form runs: `streamlit run cruise_form.py`
- ✓ Browser opens to http://localhost:8501
- ✓ Database searches return data
- ✓ Forms load and display correctly

## 🍎 macOS Versions

Tested on:
- macOS Sonoma (14.x)
- macOS Ventura (13.x)
- macOS Monterey (12.x)
- macOS Big Sur (11.x)
- macOS Catalina (10.15)

Works on both Intel and Apple Silicon (M1/M2/M3) Macs.

## 🔐 GitHub Authentication

The repository uses HTTPS with 2FA (Google Authenticator) for authentication.
You'll be prompted to authenticate when pushing changes to GitHub.

## 📊 System Requirements

| Component | Requirement |
|-----------|-------------|
| macOS | 10.15+ |
| Python | 3.9+ (3.11 recommended) |
| Disk Space | ~100 MB |
| RAM | 2 GB minimum |
| Browser | Safari, Chrome, Firefox |

---

**Ready to install? Read [SETUP_MACOS.md](SETUP_MACOS.md) for detailed instructions!**