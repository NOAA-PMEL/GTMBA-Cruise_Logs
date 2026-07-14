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

---

## Where Are My Files?

Everything is installed in your user folder:
```
C:\Users\YourName\Cruise_Logs\
```

You can browse to this folder in File Explorer to see:
- 📄 `cruise_form.py` - The main application
- 🗄️ `Cruise_Logs.db` - Your database file
- 📁 `data/` - Your cruise log data
- 📁 `exports/` - Exported files

---

## Troubleshooting

### "Anaconda not found" error
- Install Anaconda from: https://www.anaconda.com/download/
- Choose **"Just Me"** during installation
- Restart your computer after installing
- Run the installer again

### "Git not found" error
- Install Git from: https://git-scm.com/download/win
- Use default settings during installation
- Restart your computer after installing
- Run the installer again

### Desktop shortcuts don't work
Try the **Manual Launch** method above, or:
1. Run the installer again
2. When asked about shortcuts, say "yes"
3. Make sure to close any existing Cruise Logs windows first

### Application won't start
1. Open **Anaconda Prompt**
2. Type: `conda activate cruise_logs`
3. Check if it says "(cruise_logs)" at the beginning of your prompt
4. If not, the environment may not have been created properly
5. Run the installer again and say "yes" to recreate the environment

### Port already in use error
If you see "Port 8501 is already in use":
- You already have Cruise Logs running somewhere
- Close all browser windows showing Cruise Logs
- Or restart your computer

### Internet connection problems during install
- The installer downloads files from GitHub and Python packages
- Make sure you have a stable internet connection
- If it fails, close the installer and run it again
- Previously downloaded files will be kept

### Application won't start or shows errors
1. Make sure you're using a modern browser (Chrome, Firefox, or Edge)
2. Check that the conda environment is activated:
   ```
   conda activate cruise_logs
   ```
3. Try restarting the application
4. If problems persist, re-run the installer

---

## Updating Cruise Logs

To update to the latest version:
1. Download the repository again (see Step 1 above)
2. Run `INSTALL_USER.bat` again
3. When asked "Do you want to reinstall?", answer **"yes"**
4. Your database and data files will be preserved

---

## Uninstalling

To remove Cruise Logs:

1. **Delete the folder:**
   - Go to `C:\Users\YourName\Cruise_Logs\`
   - Delete the entire folder
   
2. **Remove the conda environment:**
   - Open Anaconda Prompt
   - Type: `conda remove -n cruise_logs --all -y`
   
3. **Delete desktop shortcuts:**
   - Right-click each shortcut and select "Delete"

---

## Getting Help

### Check the Documentation
- Main README: `C:\Users\YourName\Cruise_Logs\README.md`
- Field Guide: `C:\Users\YourName\Cruise_Logs\windows\FIELD_DEPLOYMENT_GUIDE.md`

### Contact Support
- GitHub Issues: https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs/issues
- Ask your IT department for help with Anaconda/Git installation

---

## FAQ

**Q: Do I need administrator rights?**  
A: No! This user installation works in your personal folder without admin privileges.

**Q: Can I install this on a laptop without internet?**  
A: You need internet for the initial installation to download files and packages. After that, Cruise Logs works offline.

**Q: Will this affect the C:\Cruise_Logs installation on field laptops?**  
A: No, these are completely separate. This installs to your user folder.

**Q: Can I move the installation folder after installing?**  
A: It's not recommended. If you need to move it, run the installer again with a different path using:
```powershell
powershell -ExecutionPolicy Bypass -File install_user.ps1 -InstallPath "D:\NewLocation\Cruise_Logs"
```

**Q: How much disk space do I need?**  
A: About 2-3 GB for the installation plus space for your data files.

**Q: Can multiple people use this on the same computer?**  
A: Yes! Each user can run the installer and get their own installation in their user folder.

---

## System Requirements

- **OS:** Windows 10 or Windows 11
- **RAM:** 4 GB minimum (8 GB recommended)
- **Disk Space:** 3 GB free space
- **Internet:** Required for installation only
- **Browser:** Modern browser (Chrome, Edge, Firefox)

---

**Version:** 1.0  
**Last Updated:** June 2026  
**Tested On:** Windows 10/11

---

*Congratulations! You're ready to use Cruise Logs! 🎉*
