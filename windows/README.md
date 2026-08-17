# Windows Setup Guide for Cruise_Logs

Complete guide for installing and configuring the Cruise_Logs system on Windows.

## Installation

👉 **Follow the [QUICKSTART_USER.md](QUICKSTART_USER.md) guide for installation!**

**Quick summary:**
- No admin privileges required
- Installs to `C:\Users\YourName\Cruise_Logs`
- Perfect for all users

**Installation steps:**
1. Run `INSTALL_USER.bat` or `install_user.ps1`
2. Wait for automated installation to complete
3. Launch using the desktop shortcut

See [QUICKSTART_USER.md](QUICKSTART_USER.md) for detailed instructions.

## Table of Contents

- [Installation](#installation)
- [GitHub Authentication](#github-authentication)
- [Troubleshooting](#troubleshooting)
- [Daily Usage](#daily-usage)
- [Git Operations](#git-operations)
- [Updating](#updating-the-installation)

---

## GitHub Authentication

**When to do this:** When you need to push changes to GitHub.

The repository uses **HTTPS with 2FA** (Google Authenticator) for authentication.

### How It Works

1. When you push changes, GitHub will prompt for authentication
2. Use your GitHub username and authenticate with Google Authenticator
3. Git can cache your credentials so you don't need to authenticate every time

### Enable Credential Caching (Optional)

To avoid entering credentials repeatedly:

```powershell
cd "$HOME\Cruise_Logs"
git config credential.helper store
```

After the first successful push, Git will remember your credentials.

---

## Troubleshooting

### Installation Issues

#### Red Error Messages During Git Clone (Cosmetic Only)

**What you see:**
```
git.exe : Cloning into 'C:\Users\YourName\Cruise_Logs'...
+ CategoryInfo          : NotSpecified: (Cloning into...)
+ FullyQualifiedErrorId : NativeCommandError
```

**Is this a problem?** **NO!** This is just a cosmetic PowerShell quirk.

**Why it happens:** Git writes progress messages to stderr (error stream), and PowerShell displays them in red even though the clone succeeded perfectly.

**What to do:** 
- ✅ If the installation continues and completes successfully, **ignore it**
- ✅ Check if `Cruise_Logs` folder was created - if yes, it worked!
- ✅ Update to the latest installer version which suppresses these cosmetic errors

**To verify it actually worked:**
```powershell
Test-Path "$HOME\Cruise_Logs\cruise_form.py"
# Should return: True
```

#### Error: "execution policy"
**Solution:** Run this first, then try installing again:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Error: "file not found"
**Solution:** Make sure you're in the correct directory:
```powershell
cd ~\Downloads  # or wherever you saved install_user.ps1
dir install_user.ps1  # verify it exists
```

#### Error: "Anaconda/Miniconda not found"
**Solution:** Install Anaconda first:
1. Download from: https://www.anaconda.com/download/
2. Run installer and check "Add Anaconda to PATH"
3. Run the installer again

#### Error: "Git is not installed"
**Solution:** Install Git:
1. Download from: https://git-scm.com/download/win
2. Run installer and select "Add Git to PATH"
3. Run the installer again

#### Installation hangs
**Symptoms:** No new text for 10+ minutes

**Solution:** This is usually normal during package installation. However:
- Wait up to 30 minutes
- If truly stuck, press `Ctrl+C` and run again
- Check your internet connection

### GitHub Authentication Issues

#### Error: "Could not resolve host: github.com"
**Causes:**
- No internet connection
- Firewall blocking GitHub
- VPN/proxy issues

**Solution:**
1. Check internet connection
2. Try: `ping github.com`
3. Check firewall settings
4. If on corporate network, talk to IT about GitHub access

#### Error: "Authentication failed"
**Causes:**
- Incorrect credentials
- 2FA not completed
- Credentials not cached

**Solution:**
1. Make sure you're using your GitHub username (not email)
2. Complete 2FA authentication with Google Authenticator
3. Enable credential caching (see GitHub Authentication section above)

### Application Issues

#### Port 8501 already in use
**Solution:** Streamlit will auto-select the next available port (8502, 8503, etc.)

Or kill existing process:
```powershell
Get-Process -Name python | Stop-Process -Force
```

#### Database locked error
**Solution:**
```powershell
# Close all Cruise_Logs applications
# Then restart
```

#### Module not found errors
**Solution:**
```powershell
conda activate cruise_logs
pip install -r "$HOME\Cruise_Logs\requirements.txt"
```

---

## Daily Usage

### Method 1: Desktop Shortcut (Easiest)

Double-click **"Cruise Logs - Main Form"** on your desktop

### Method 2: Command Line

```powershell
# Open PowerShell (doesn't need to be Administrator)
conda activate cruise_logs
cd "$HOME\Cruise_Logs"
streamlit run cruise_form.py
```

### Method 3: Launcher Menu

```powershell
conda activate cruise_logs
cd "$HOME\Cruise_Logs"
python launcher.py
```

### Stopping the Application

Press `Ctrl+C` in the PowerShell window, or just close the window.

---

## Git Operations

### Pull Latest Changes

```powershell
cd "$HOME\Cruise_Logs"
git pull origin main
```

### Push Your Changes

```powershell
cd "$HOME\Cruise_Logs"
git add Cruise_Logs.db
git commit -m "Updated cruise logs - [your description]"
git push origin main
```

### Check Status

```powershell
cd "$HOME\Cruise_Logs"
git status
```

### View Remote URL

```powershell
cd "$HOME\Cruise_Logs"
git remote get-url origin
# Should show: https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs.git
```

---

## Updating the Installation

### Update Code

```powershell
cd "$HOME\Cruise_Logs"
git pull origin main
```

### Update Python Packages

```powershell
conda activate cruise_logs
pip install --upgrade -r "$HOME\Cruise_Logs\requirements.txt"
```

### Update Conda Environment

```powershell
conda update --all -n cruise_logs
```

---

## Advanced Configuration

### Custom Install Location

By default, the installer uses `C:\Users\YourName\Cruise_Logs`. The installation location is optimized for user access without admin privileges.

### Environment Variables

If you need to modify paths, edit these files:
- `$HOME\Cruise_Logs\config.py` - Database paths
- Conda environment: Managed by Anaconda

---

## System Requirements

| Component | Requirement |
|-----------|-------------|
| Windows | 10 or 11 |
| Processor | Intel/AMD x64 |
| RAM | 4 GB minimum, 8 GB recommended |
| Disk Space | ~500 MB for install + database |
| Internet | Required for installation |

---

## Additional Resources

### For Users
- **User Quick Start:** `QUICKSTART_USER.md`
- **User Instructions:** `INSTALL_INSTRUCTIONS_USER.txt`
- **Installation Overview:** `USER_INSTALLATION_FILES.md`

### General
- **Main README:** `../README.md`
- **GitHub Issues:** https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs/issues

---

## Quick Reference

```powershell
# Activate environment
conda activate cruise_logs

# Start main form
streamlit run "$HOME\Cruise_Logs\cruise_form.py"

# Start launcher
python "$HOME\Cruise_Logs\launcher.py"

# Check Git status
cd "$HOME\Cruise_Logs" && git status

# Pull latest changes
cd "$HOME\Cruise_Logs" && git pull

# Push your changes
cd "$HOME\Cruise_Logs"
git add Cruise_Logs.db
git commit -m "Update"
git push
```

---

## Getting Help

1. **Check this README** for common solutions
2. **Check INSTALL_COMMAND.txt** for installation help
3. **Check Git output** for specific error messages
4. **Create GitHub issue** with error details and screenshots

---

**Installation Complete! 🎉**

You're ready when:
- ✓ Desktop shortcut launches the application
- ✓ Browser opens to http://localhost:8501
- ✓ Forms load correctly
- ✓ (Optional) `git fetch` works without password

**Happy cruising! 🚢**
