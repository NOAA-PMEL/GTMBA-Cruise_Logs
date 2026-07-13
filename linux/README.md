# Cruise Logs - Linux Installation

This directory contains installation scripts and documentation for running Cruise Logs on Linux systems.

## Quick Start

### One-Line Installation

Download and run the installer:

```bash
curl -O https://raw.githubusercontent.com/NOAA-PMEL/GTMBA-Cruise_Logs/main/linux/install_user.sh
bash install_user.sh
```

Or if you already have the repository:

```bash
cd /path/to/GTMBA-Cruise_Logs/linux
./install_user.sh
```

## What the Installer Does

The `install_user.sh` script will:

1. ✅ Check for Anaconda/Miniconda installation
2. ✅ Check for Git installation
3. ✅ Clone/update the Cruise Logs repository to `~/Cruise_Logs`
4. ✅ Create a Python 3.11 conda environment named `cruise_logs`
5. ✅ Install all required Python packages (streamlit, pandas, etc.)
6. ✅ Verify the installation
7. ✅ Create convenient launch scripts

**No sudo/root privileges required!** Everything installs in your home directory.

## System Requirements

### Minimum Requirements
- **OS**: Any modern Linux distribution (Ubuntu, Debian, Fedora, RHEL, CentOS, etc.)
- **RAM**: 4 GB (8 GB recommended)
- **Disk Space**: 2 GB free space
- **Internet**: Required for initial setup

### Required Software
- **Anaconda or Miniconda**: Python package management
  - Download from: https://www.anaconda.com/download/ or https://docs.conda.io/en/latest/miniconda.html
  - Quick install (Miniconda):
    ```bash
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh
    ```

- **Git**: Version control system
  - Ubuntu/Debian: `sudo apt-get install git`
  - Fedora/RHEL: `sudo dnf install git` or `sudo yum install git`

## Installation Options

### Option 1: Automated Installation (Recommended)

Run the installation script:

```bash
./install_user.sh
```

The script will guide you through the process and check for all prerequisites.

### Option 2: Manual Installation

If you prefer to install manually:

1. **Install prerequisites**:
   ```bash
   # Install Git (if not already installed)
   sudo apt-get update && sudo apt-get install git  # Ubuntu/Debian
   # or
   sudo dnf install git  # Fedora/RHEL
   
   # Install Miniconda (if not already installed)
   wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
   bash Miniconda3-latest-Linux-x86_64.sh
   ```

2. **Clone the repository**:
   ```bash
   git clone https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs.git ~/Cruise_Logs
   cd ~/Cruise_Logs
   ```

3. **Create conda environment**:
   ```bash
   conda create -n cruise_logs python=3.11 -y
   conda activate cruise_logs
   ```

4. **Install Python packages**:
   ```bash
   pip install -r requirements.txt
   ```

5. **Launch the application**:
   ```bash
   streamlit run cruise_form.py
   ```

## Launching Cruise Logs

After installation, you have several options to launch the application:

### Method 1: Using the Launch Script (Easiest)

```bash
cd ~/Cruise_Logs
./start_cruise_logs.sh
```

### Method 2: Using the GUI Launcher

```bash
cd ~/Cruise_Logs
./start_cruise_logs_gui.sh
```

### Method 3: Manual Launch

```bash
conda activate cruise_logs
cd ~/Cruise_Logs
streamlit run cruise_form.py
```

The application will open in your default web browser at `http://localhost:8501`.

## Updating Cruise Logs

To update to the latest version:

1. **Using the installer** (recommended):
   ```bash
   cd ~/Cruise_Logs/linux  # or wherever you saved install_user.sh
   ./install_user.sh
   ```
   
   When prompted, answer "yes" to reinstall.

2. **Manual update**:
   ```bash
   cd ~/Cruise_Logs
   git pull origin main
   conda activate cruise_logs
   pip install -r requirements.txt --upgrade
   ```

## Troubleshooting

### Conda Terms of Service Error

If you see an error about Terms of Service not being accepted:

```
CondaToSNonInteractiveError: Terms of Service have not been accepted
```

You have two options:

**Option 1: Accept the Terms of Service (if you agree)**
```bash
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
```

**Option 2: Use conda-forge instead (recommended)**
The updated installer now uses conda-forge channels which don't require ToS acceptance. Simply re-run the installer:
```bash
cd ~/Cruise_Logs/linux
./install_user.sh
```

Or manually create the environment with conda-forge:
```bash
conda create -n cruise_logs python=3.11 -y -c conda-forge --override-channels
conda activate cruise_logs
pip install -r ~/Cruise_Logs/requirements.txt
```

### Network Timeout Errors During Installation

If you see timeout errors when installing packages:

```
WARNING: Retrying after connection broken by 'ReadTimeoutError'
ERROR: Could not find a version that satisfies the requirement streamlit
```

This means your connection to PyPI is slow or unstable. Try these solutions:

**Solution 1: Run the installer again**
The updated installer now uses longer timeouts and will automatically retry:
```bash
cd ~/Cruise_Logs/linux
./install_user.sh
```

**Solution 2: Manual installation with extended timeout**
```bash
conda activate cruise_logs
cd ~/Cruise_Logs
pip install --timeout=300 --retries=10 -r requirements.txt
```

**Solution 3: Use a PyPI mirror (if in China or experiencing slow connections)**
```bash
conda activate cruise_logs
cd ~/Cruise_Logs
# Using Tsinghua mirror (China)
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt
# OR using Aliyun mirror (China)
pip install -i https://mirrors.aliyun.com/pypi/simple -r requirements.txt
```

**Solution 4: Configure proxy (if behind corporate firewall)**
```bash
export http_proxy=http://proxy.example.com:8080
export https_proxy=http://proxy.example.com:8080
pip install -r requirements.txt
```

**Solution 5: Install packages individually**
```bash
conda activate cruise_logs
pip install --timeout=300 streamlit
pip install --timeout=300 pandas xlrd openpyxl numpy et-xmlfile
```

### Conda not found

If the installer can't find conda, make sure it's in your PATH:

```bash
# Add to your ~/.bashrc or ~/.bash_profile
export PATH="$HOME/miniconda3/bin:$PATH"

# Then reload your shell
source ~/.bashrc
```

Or initialize conda:

```bash
~/miniconda3/bin/conda init bash
# Close and reopen your terminal
```

### Git not found

Install git for your distribution:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install git

# Fedora
sudo dnf install git

# RHEL/CentOS 7
sudo yum install git

# RHEL/CentOS 8+
sudo dnf install git
```

### Port Already in Use

If you see an error about port 8501 being in use:

```bash
# Find and kill the process using port 8501
lsof -ti:8501 | xargs kill -9

# Or use a different port
streamlit run cruise_form.py --server.port 8502
```

### Permission Denied

If you get permission errors:

```bash
# Make the script executable
chmod +x install_user.sh

# Or run with bash explicitly
bash install_user.sh
```

### Browser Doesn't Open Automatically

If your browser doesn't open automatically:

1. Look for the URL in the terminal output (usually `http://localhost:8501`)
2. Open your browser manually and navigate to that URL

### Display Issues (Headless Servers)

If you're running on a server without a display:

```bash
# Forward the port through SSH
ssh -L 8501:localhost:8501 user@your-server

# Or access from another machine
streamlit run cruise_form.py --server.address 0.0.0.0
```

## Uninstallation

To completely remove Cruise Logs:

```bash
# Remove the installation directory
rm -rf ~/Cruise_Logs

# Remove the conda environment
conda env remove -n cruise_logs
```

## Distribution-Specific Notes

### Ubuntu/Debian
Works out of the box with standard packages. Tested on Ubuntu 20.04, 22.04, and 24.04.

### Fedora/RHEL/CentOS
May need to enable EPEL repository for some dependencies:
```bash
sudo dnf install epel-release  # Fedora/RHEL 8+
sudo yum install epel-release  # RHEL/CentOS 7
```

### Arch Linux
Install conda via AUR or use the standard Miniconda installer.

### WSL (Windows Subsystem for Linux)
Fully supported! Follow the same instructions as regular Linux.
The browser will open in Windows automatically.

## Support

For issues specific to Linux installation:
- Check the [main README](../README.md)
- Review this troubleshooting section
- Check GitHub issues: https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs/issues

## File Locations

- **Application**: `~/Cruise_Logs/`
- **Database**: `~/Cruise_Logs/Cruise_Logs.db`
- **Backups**: `~/Cruise_Logs/backups/`
- **Launch Scripts**: `~/Cruise_Logs/start_cruise_logs.sh`
- **Conda Environment**: `~/miniconda3/envs/cruise_logs/` (or `~/anaconda3/envs/cruise_logs/`)
