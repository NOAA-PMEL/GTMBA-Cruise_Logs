# GitHub SSH Setup for Cruise_Logs

This document explains how to set up SSH access for pushing database updates to GitHub.

## Why SSH?

Field computers need to push the updated `Cruise_Logs.db` file back to GitHub after entering new cruise data. SSH provides:
- ✅ Secure authentication without storing passwords
- ✅ No need to enter credentials for each push
- ✅ Works reliably on research vessels with limited connectivity

## When to Run This

Run the SSH setup script **AFTER** the initial installation:
1. Complete the installation using `install.ps1` (Windows) or the macOS installer
2. Verify the application works
3. Run the SSH setup script before your first cruise

## Windows Setup

### Prerequisites
- Cruise_Logs already installed (via `install.ps1`)
- Git for Windows installed
- GitHub account with access to NOAA-PMEL/GTMBA-Cruise_Logs

### Run the Script

Open PowerShell and run:

```powershell
cd C:\Cruise_Logs\windows
powershell -ExecutionPolicy Bypass -File setup_github_ssh.ps1
```

Or with your email pre-filled:

```powershell
powershell -ExecutionPolicy Bypass -File setup_github_ssh.ps1 -Email "your.email@noaa.gov"
```

### What the Script Does

1. **Checks for Git** - Verifies Git is installed
2. **Gets your information** - Asks for your GitHub email and name
3. **Generates SSH key** - Creates `~/.ssh/id_ed25519` (or uses existing)
4. **Configures SSH** - Sets up `~/.ssh/config` for GitHub
5. **Displays public key** - Shows your public key and copies it to clipboard
6. **Waits for you** - Pause while you add the key to GitHub
7. **Tests connection** - Verifies SSH works with GitHub
8. **Switches remote** - Changes from HTTPS to SSH
9. **Tests push** - Confirms you can push to the repository

## macOS Setup

### Prerequisites
- Cruise_Logs already installed
- Git installed (via Xcode Command Line Tools or Homebrew)
- GitHub account with access to NOAA-PMEL/GTMBA-Cruise_Logs

### Run the Script

Open Terminal and run:

```bash
cd ~/NOAA-GitHub/GTMBA-Cruise_Logs/macos
bash setup_github_ssh.sh
```

Or with your email:

```bash
bash setup_github_ssh.sh your.email@noaa.gov
```

### macOS-Specific Features

The macOS script also:
- Adds the key to your macOS Keychain for persistence
- Configures SSH to use the Keychain automatically
- Sets proper permissions on all SSH files

## Adding SSH Key to GitHub

When the script pauses and displays your public key:

1. **Copy the key** (already in your clipboard!)
2. **Go to GitHub**: https://github.com/settings/ssh/new
3. **Title**: Enter something like "Cruise_Logs - SHIP_NAME"
4. **Key**: Paste your public key
5. **Click** "Add SSH key"
6. **Return to the script** and press Enter

## Verifying Setup

After completion, test with:

```bash
# Check remote is using SSH
git remote get-url origin
# Should show: git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git

# Test connection
ssh -T git@github.com
# Should show: "Hi username! You've successfully authenticated..."
```

## Pushing Database Updates

After entering cruise data:

### Windows (PowerShell or Command Prompt)
```powershell
cd C:\Cruise_Logs
git add Cruise_Logs.db
git commit -m "Updated cruise logs - [CRUISE_NAME] [DATE]"
git push origin main
```

### macOS (Terminal)
```bash
cd ~/Cruise_Logs
git add Cruise_Logs.db
git commit -m "Updated cruise logs - [CRUISE_NAME] [DATE]"
git push origin main
```

## Troubleshooting

### "Permission denied (publickey)"

**Problem**: SSH key not added to GitHub or not being used

**Solutions**:
1. Verify key is added to GitHub: https://github.com/settings/keys
2. Test connection: `ssh -T git@github.com`
3. Check SSH config: `cat ~/.ssh/config` (macOS/Linux) or `type %USERPROFILE%\.ssh\config` (Windows)

### "Repository not found"

**Problem**: Don't have access to NOAA-PMEL/GTMBA-Cruise_Logs

**Solution**: Contact the repository administrator to be added as a collaborator

### "Host key verification failed"

**Problem**: First time connecting to GitHub

**Solution**: Run `ssh -T git@github.com` and type "yes" when prompted

### Key Already Exists

If you already have an SSH key:
- The script will ask if you want to use it
- Say "yes" to keep your existing key
- Say "no" to backup the old key and create a new one

### Windows: ssh-keygen not found

**Problem**: Git for Windows not in PATH

**Solution**: 
1. Reinstall Git for Windows
2. During installation, select "Git from the command line and also from 3rd-party software"

### macOS: Permission Denied

**Problem**: Script doesn't have execute permission

**Solution**:
```bash
chmod +x ~/NOAA-GitHub/GTMBA-Cruise_Logs/macos/setup_github_ssh.sh
```

## Security Notes

- 🔒 **Private key stays on your computer** - Never share `~/.ssh/id_ed25519`
- ✅ **Public key is safe to share** - The `.pub` file goes to GitHub
- 🚫 **No passwords stored** - SSH keys are more secure than passwords
- 🔑 **One key per computer** - Generate a new key for each field computer

## Multiple Computers

Each field computer should have its own SSH key:
1. Run the setup script on each computer
2. Add each computer's public key to your GitHub account
3. Use descriptive titles like:
   - "Cruise_Logs - RV_ATLANTIS"
   - "Cruise_Logs - RV_DISCOVERY"
   - "Cruise_Logs - FIELD_LAPTOP"

## Removing SSH Keys

To remove a key from GitHub (e.g., when decommissioning a computer):
1. Go to: https://github.com/settings/keys
2. Find the key (by title)
3. Click "Delete"

## Support

For help:
- Check the main README.md
- Contact: brian.lake@noaa.gov
- GitHub Issues: https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs/issues
