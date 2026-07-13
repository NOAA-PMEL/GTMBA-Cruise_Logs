# Cruise Logs Installation Guide

Complete installation instructions for all platforms. Choose your operating system below.

## Platform-Specific Installation

| Platform | Quick Start | Full Documentation |
|----------|-------------|-------------------|
| **Windows** | [windows/INSTALL_USER.bat](windows/INSTALL_USER.bat) | [windows/](windows/) |
| **macOS** | [macos/install_user.sh](macos/install_user.sh) | [macos/README.md](macos/README.md) |
| **Linux** | [linux/install_user.sh](linux/install_user.sh) | [linux/README.md](linux/README.md) |

---

## Windows Installation

### Quick Start

1. **Download the installer** from the `windows` folder
2. **Double-click** `INSTALL_USER.bat`
3. **Follow the prompts** - the installer will guide you through everything

The installer automatically:
- ✅ Checks for Anaconda and Git
- ✅ Clones the repository to `C:\Users\YourName\Cruise_Logs`
- ✅ Creates the Python environment
- ✅ Installs required packages
- ✅ Creates desktop shortcuts
- ✅ No admin privileges required!

### Requirements
- Windows 10 or later
- Anaconda or Miniconda
- Git for Windows

### Launch After Installation
- Double-click the **"Cruise Logs - Launcher"** icon on your desktop

[See detailed Windows documentation →](windows/)

---

## macOS Installation

### Quick Start

Open Terminal and run:

```bash
curl -O https://raw.githubusercontent.com/NOAA-PMEL/GTMBA-Cruise_Logs/main/macos/install_user.sh
bash install_user.sh
```

Or if you already have the repository:

```bash
cd /path/to/GTMBA-Cruise_Logs/macos
./install_user.sh
```

The installer automatically:
- ✅ Checks for Anaconda and Git
- ✅ Clones the repository to `~/Cruise_Logs`
- ✅ Creates the Python environment
- ✅ Installs required packages
- ✅ Creates launch scripts
- ✅ No sudo required!

### Requirements
- macOS 10.15 (Catalina) or later
- Anaconda or Miniconda
- Git (via Xcode Command Line Tools or Homebrew)

### Launch After Installation
```bash
cd ~/Cruise_Logs
./start_cruise_logs.sh
```

[See detailed macOS documentation →](macos/README.md)

---

## Linux Installation

### Quick Start

Open terminal and run:

```bash
curl -O https://raw.githubusercontent.com/NOAA-PMEL/GTMBA-Cruise_Logs/main/linux/install_user.sh
bash install_user.sh
```

Or if you already have the repository:

```bash
cd /path/to/GTMBA-Cruise_Logs/linux
./install_user.sh
```

The installer automatically:
- ✅ Checks for Anaconda and Git
- ✅ Clones the repository to `~/Cruise_Logs`
- ✅ Creates the Python environment
- ✅ Installs required packages
- ✅ Creates launch scripts
- ✅ No sudo required!

### Requirements
- Any modern Linux distribution (Ubuntu, Debian, Fedora, RHEL, CentOS, Arch, etc.)
- Anaconda or Miniconda
- Git

### Launch After Installation
```bash
cd ~/Cruise_Logs
./start_cruise_logs.sh
```

[See detailed Linux documentation →](linux/README.md)

---

## Manual Installation (All Platforms)

If you prefer to install manually without using the automated scripts:

### 1. Install Prerequisites

**Anaconda or Miniconda** (Python package manager):
- Download from: https://www.anaconda.com/download/
- Or Miniconda (lightweight): https://docs.conda.io/en/latest/miniconda.html

**Git** (version control):
- Windows: https://git-scm.com/download/win
- macOS: `xcode-select --install` or `brew install git`
- Linux: `sudo apt-get install git` (Ubuntu/Debian) or `sudo dnf install git` (Fedora/RHEL)

### 2. Clone the Repository

```bash
# Choose your installation directory
git clone https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs.git ~/Cruise_Logs
cd ~/Cruise_Logs
```

### 3. Create Python Environment

```bash
conda create -n cruise_logs python=3.11 -y
conda activate cruise_logs
```

### 4. Install Python Packages

```bash
pip install -r requirements.txt
```

### 5. Launch the Application

```bash
streamlit run cruise_form.py
```

The application will open in your browser at http://localhost:8501

---

## Updating Cruise Logs

### Using the Installer (Recommended)

**Windows:**
1. Run `INSTALL_USER.bat` again
2. Choose "yes" when asked to reinstall

**macOS/Linux:**
```bash
cd ~/Cruise_Logs/macos  # or ~/Cruise_Logs/linux
./install_user.sh
```
Choose "yes" when asked to reinstall.

### Manual Update

```bash
cd ~/Cruise_Logs  # or C:\Users\YourName\Cruise_Logs on Windows
git pull origin main
conda activate cruise_logs
pip install -r requirements.txt --upgrade
```

---

## Launching Cruise Logs

### Windows
- **Easy**: Double-click "Cruise Logs - Launcher" on your desktop
- **Manual**: Open Anaconda Prompt, then:
  ```cmd
  conda activate cruise_logs
  cd C:\Users\YourName\Cruise_Logs
  streamlit run cruise_form.py
  ```

### macOS/Linux
- **Easy**: Run the launch script:
  ```bash
  cd ~/Cruise_Logs
  ./start_cruise_logs.sh
  ```
- **Manual**: Open terminal, then:
  ```bash
  conda activate cruise_logs
  cd ~/Cruise_Logs
  streamlit run cruise_form.py
  ```

---

## Common Issues

### Conda Not Found

**Windows:**
- Make sure you selected "Add Anaconda to PATH" during installation
- Or use "Anaconda Prompt" from the Start Menu

**macOS/Linux:**
```bash
# Initialize conda for your shell
~/miniconda3/bin/conda init bash  # or zsh for macOS
# Close and reopen terminal
```

### Git Not Found

**Windows:**
- Reinstall Git and make sure "Add Git to PATH" is selected

**macOS:**
```bash
xcode-select --install
```

**Linux:**
```bash
sudo apt-get install git  # Ubuntu/Debian
sudo dnf install git      # Fedora/RHEL
```

### Port Already in Use

If port 8501 is already in use:

```bash
# Find and kill the process
# Windows (PowerShell):
Get-Process -Id (Get-NetTCPConnection -LocalPort 8501).OwningProcess | Stop-Process

# macOS/Linux:
lsof -ti:8501 | xargs kill -9

# Or use a different port:
streamlit run cruise_form.py --server.port 8502
```

### Browser Doesn't Open

Manually open your browser and go to:
- http://localhost:8501

---

## System Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | Windows 10+, macOS 10.15+, or any modern Linux |
| **Python** | 3.11 (automatically installed via conda) |
| **RAM** | 4 GB minimum (8 GB recommended) |
| **Disk Space** | 2 GB free space |
| **Internet** | Required for initial installation |
| **Browser** | Chrome, Firefox, Safari, or Edge |

---

## Installation Locations

Default installation directories:

- **Windows**: `C:\Users\YourName\Cruise_Logs`
- **macOS/Linux**: `~/Cruise_Logs`

The database and all application files are stored in this directory.

---

## Getting Help

1. **Check the platform-specific documentation:**
   - [Windows Documentation](windows/)
   - [macOS Documentation](macos/README.md)
   - [Linux Documentation](linux/README.md)

2. **Check the main README**: [README.md](README.md)

3. **Run the verification script:**
   ```bash
   conda activate cruise_logs
   python verify_setup.py
   ```

4. **Report issues**: https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs/issues

---

## Features

Once installed, you can:
- 📝 Log cruise information and activities
- 🔍 Search and manage equipment inventory
- 📊 Track deployments and recoveries
- 🔧 Record maintenance and repairs
- 💾 Automatic database backups
- 🔄 Sync with remote repositories

---

## Next Steps

After successful installation:

1. **Launch the application** using your preferred method
2. **Familiarize yourself** with the interface
3. **Set up backups** (see [BACKUP_SETUP.md](BACKUP_SETUP.md))
4. **Configure sync** if working with a team (see [DATABASE_SYNC_WORKFLOW.md](DATABASE_SYNC_WORKFLOW.md))

---

**Installation complete? You're ready to start logging cruise data!** 🚢
