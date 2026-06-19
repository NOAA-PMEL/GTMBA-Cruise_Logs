# User Installation Files - Reference Guide

This document lists all the files created for user-space installation of Cruise Logs.

---

## Installation Files

All files are located in the `windows/` directory for better organization.

### Primary Installer
- **`windows/install_user.ps1`** - PowerShell installation script  
  Installs Cruise Logs to `C:\Users\USERNAME\Cruise_Logs`  
  No administrator privileges required

### Easy Launcher
- **`windows/INSTALL_USER.bat`** - Batch file for easy double-click installation  
  Just double-click this file to start the installer

---

## Documentation Files

### Quick Reference
- **`windows/INSTALL_INSTRUCTIONS_USER.txt`** - One-page printable instructions  
  Perfect for emailing or printing for your boss

### Comprehensive Guide
- **`windows/QUICKSTART_USER.md`** - Complete user guide with troubleshooting  
  Includes FAQ, system requirements, and detailed help

### Reference Guide
- **`windows/USER_INSTALLATION_FILES.md`** - This file!
  Overview of all installation files and how to use them

### Main README
- **`README.md`** (in project root) - Updated to include user installation options  
  Now shows both field laptop and user installation methods

---

## How to Share with Users

### Option 1: Give Them Everything
Share the entire repository and tell them to:
1. Download all files
2. Navigate to the `windows` folder
3. Double-click `INSTALL_USER.bat`
4. Follow the prompts

### Option 2: Share Just the Windows Folder
Send them the `windows` folder containing:
- `install_user.ps1`
- `INSTALL_USER.bat`
- `QUICKSTART_USER.md`

### Option 3: Email Instructions
Send them `INSTALL_INSTRUCTIONS_USER.txt` and `install_user.ps1`

### Option 4: Share the Repository Link
Tell them to:
1. Go to: https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs
2. Click the green "Code" button → Download ZIP
3. Extract the ZIP file
4. Navigate to the `windows` folder
5. Run `INSTALL_USER.bat` or `install_user.ps1`

---

## Installation Comparison

| Feature | Field Laptop | User Install |
|---------|--------------|-------------|
| Script | `windows/install.ps1` | `windows/install_user.ps1` |
| Install Location | `C:\Cruise_Logs` | `C:\Users\USERNAME\Cruise_Logs` |
| Admin Required | Recommended | **No** |
| Target Users | Field technicians | Office staff, managers |
| Shared Environment | Single machine setup | Per-user setup |
| Desktop Shortcuts | Yes | Yes |
| Conda Environment | `cruise_logs` | `cruise_logs` |

---

## Key Differences from Field Installation

1. **Location**: Installs to user's home directory instead of `C:\Cruise_Logs`
2. **Permissions**: No admin rights needed
3. **User-friendly**: More explanatory messages for non-technical users
4. **Smart Updates**: Detects existing installations and offers to update
5. **Environment Check**: Checks if conda environment already exists
6. **Isolated**: Each user on a shared computer gets their own installation

---

## Installation Steps Summary

For your boss or other users, here's what happens:

1. **Prerequisites Check**
   - Looks for Anaconda/Miniconda
   - Looks for Git
   - Gives clear instructions if missing

2. **Repository Setup**
   - Clones from GitHub to user folder
   - Handles existing installations gracefully

3. **Environment Creation**
   - Creates `cruise_logs` conda environment
   - Installs all required packages

4. **Verification**
   - Checks database and required files
   - Reports any issues

5. **Desktop Shortcuts**
   - Creates easy-launch icons (optional)
   - Both Main Form and Launcher options

6. **Completion**
   - Shows installation summary
   - Provides launch instructions
   - Lists help resources

---

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| Anaconda not found | Install from anaconda.com, restart, retry |
| Git not found | Install from git-scm.com, restart, retry |
| PowerShell won't run script | Use `INSTALL_USER.bat` instead |
| Port already in use | Close all Cruise Logs browser windows |
| Shortcuts don't work | Use Anaconda Prompt method |
| Want to reinstall | Run installer again, say "yes" to reinstall |

---

## Testing the Installation

Before sharing with users, test by:

1. Running `install_user.ps1` on a clean machine (or VM)
2. Verifying desktop shortcuts work
3. Launching Cruise Logs and entering test data
4. Checking that database saves properly
5. Trying an update (run installer again)

---

## Support Resources

Point users to:
- `windows/QUICKSTART_USER.md` - For detailed help
- `windows/INSTALL_INSTRUCTIONS_USER.txt` - For quick reference  
- GitHub Issues - For bug reports
- You! - For NOAA-specific questions

---

## Future Enhancements

Potential improvements:
- [ ] Create a graphical installer (GUI)
- [ ] Add auto-update feature
- [ ] Include sample data for testing
- [ ] Create video tutorial
- [ ] Add uninstaller script
- [ ] Bundle Anaconda/Git in offline installer

---

**Created:** June 2026  
**For:** NOAA PMEL GTMBA Cruise Logs  
**Version:** 1.0
