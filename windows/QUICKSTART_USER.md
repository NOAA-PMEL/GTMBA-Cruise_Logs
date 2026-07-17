# Quick Start Guide - Cruise Logs (User Installation)

**For installing Cruise Logs in your personal user folder**  
*No administrator privileges required!*

---

## What You'll Need

Before starting, make sure you have these two programs installed:

1. **Anaconda** (for Python) - [Download here](https://www.anaconda.com/download/)
2. **Git** (for downloading files) - [Download here](https://git-scm.com/download/win)

> 💡 **Tip:** During installation of both programs, use the default/recommended settings. Just keep clicking "Next"!

---

## Installation Steps

### Step 1: Download the Repository

1. Go to the Cruise Logs repository: https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs
2. Click the green **"Code"** button
3. Select **"Download ZIP"**
4. Save the file and extract it to a location like your Desktop or Downloads folder

### Step 2: Run the Installer

1. Open the extracted `GTMBA-Cruise_Logs-main` folder
2. Open the `windows` folder
3. Double-click **`INSTALL_USER.bat`**
4. If you see a security warning, click **"Run anyway"** or **"Yes"**

> 💡 **Tip:** The installer is just a simple batch file that launches the PowerShell installer for you!

### Step 3: Follow the Prompts

The installer will guide you through:
- ✅ Finding Anaconda on your computer
- ✅ Finding Git on your computer  
- ✅ Downloading Cruise Logs files
- ✅ Setting up Python packages
- ✅ Creating desktop shortcuts

Just answer the questions as they appear. When asked about shortcuts, say **"yes"** - it makes launching much easier!

### Step 4: Wait for Installation

The installation takes about 5-10 minutes depending on your internet speed. You'll see:
- Downloading files from GitHub
- Creating Python environment
- Installing packages (this is the longest part)

☕ **Good time for coffee!**

> ⚠️ **Note:** You may see red error-like messages during "Cloning into..." - these are just cosmetic PowerShell warnings and can be ignored. If the installation continues, everything is working correctly! See [POWERSHELL_GIT_ERRORS.md](POWERSHELL_GIT_ERRORS.md) for details.

---

## Launching Cruise Logs

Once installed, you have two easy options:

### Option 1: Desktop Shortcut (Recommended)
Simply double-click the **"Cruise Logs - Main Form"** icon on your desktop!

### Option 2: Launcher
Double-click the **"Cruise Logs - Launcher"** icon for a menu with options.

### Option 3: Manual Launch
If shortcuts don't work:
1. Open **Anaconda Prompt** (search in Start Menu)
2. Type these commands (press Enter after each):
   ```
   conda activate cruise_logs
   cd %USERPROFILE%\Cruise_Logs
   streamlit run cruise_form.py
   ```
