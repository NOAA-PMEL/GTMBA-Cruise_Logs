# Git Setup Guide - HTTPS to SSH Conversion

This document explains the repository's Git authentication strategy.

## Overview

The Cruise_Logs repository supports a **two-stage authentication approach**:

1. **Initial Installation (HTTPS)** - Easy for everyone, no SSH keys required
2. **Post-Installation SSH Setup (Optional)** - For users who need to push/pull changes

This gives you the **best of both worlds**: easy installation for new users, with the option to upgrade to SSH for development work.

---

## Stage 1: Initial Installation (HTTPS)

### Why HTTPS First?

- ✅ Works immediately without any SSH configuration
- ✅ No prerequisites - works on any machine with Git
- ✅ No firewall issues (uses standard HTTPS port 443)
- ✅ Perfect for initial downloads and installations

### How It Works

The installation scripts (`install.ps1` for Windows, cloning instructions for macOS) use HTTPS to clone the repository:

```bash
git clone https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs.git
```

This allows anyone to install the system without needing:
- SSH keys
- GitHub account configuration
- Special network settings

---

## Stage 2: SSH Setup (Optional)

### When to Use SSH

You should set up SSH authentication if you plan to:
- **Push changes** back to the repository
- **Pull updates** regularly
- **Contribute** to development
- **Sync databases** between systems

### Why SSH?

- 🔐 **More secure** - Uses cryptographic keys instead of passwords
- ⚡ **More convenient** - No password prompts for git operations
- ✅ **Required for push access** - GitHub requires SSH or tokens for write operations

### How to Set Up SSH

Both platforms have automated scripts to convert from HTTPS to SSH:

#### Windows

```powershell
cd C:\Cruise_Logs\windows
powershell -ExecutionPolicy Bypass -File setup_github_ssh.ps1
```

#### macOS/Linux

```bash
cd ~/NOAA-GitHub/GTMBA-Cruise_Logs/macos
bash setup_github_ssh.sh
```

### What the Scripts Do

1. **Check for SSH keys** - Looks for existing keys in `~/.ssh/`
2. **Generate keys if needed** - Creates new ed25519 key if none found
3. **Display public key** - Shows your public key and copies to clipboard
4. **Guide GitHub setup** - Walks through adding key to GitHub account
5. **Test connection** - Verifies SSH works with GitHub
6. **Convert remote** - Changes repository from HTTPS to SSH
7. **Verify** - Tests that git operations work over SSH

After running the script, your repository remote will be changed from:
```
https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs.git
```

To:
```
git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git
```

---

## Checking Your Current Setup

### View Current Remote URL

**Windows:**
```powershell
cd C:\Cruise_Logs
git remote get-url origin
```

**macOS:**
```bash
cd ~/NOAA-GitHub/GTMBA-Cruise_Logs
git remote get-url origin
```

### Interpreting the Output

If you see:
- `https://github.com/...` → Using HTTPS (initial install)
- `git@github.com:...` → Using SSH (post-setup)

---

## Manual Conversion (If Scripts Don't Work)

If the automated scripts have issues, you can convert manually:

### 1. Set up SSH keys with GitHub

Follow GitHub's guide: https://docs.github.com/en/authentication/connecting-to-github-with-ssh

### 2. Test SSH connection

```bash
ssh -T git@github.com
```

You should see: "Hi username! You've successfully authenticated..."

### 3. Change the remote URL

```bash
cd /path/to/GTMBA-Cruise_Logs
git remote set-url origin git@github.com:NOAA-PMEL/GTMBA-Cruise_Logs.git
```

### 4. Verify

```bash
git remote get-url origin
git fetch origin
```

---

## Troubleshooting

### "Could not resolve host: github.com"

**For HTTPS:**
- Check internet connection
- Check if GitHub is accessible: `ping github.com`
- Check firewall/proxy settings

**For SSH:**
- Same as above, plus:
- Check if SSH port (22) is open
- Some networks block SSH - may need to stay with HTTPS

### "Permission denied (publickey)"

This means SSH key is not properly configured:
1. Make sure key is added to GitHub: https://github.com/settings/keys
2. Check ssh-agent is running
3. Verify key is loaded: `ssh-add -l`
4. Test connection: `ssh -T git@github.com`

### "fatal: Authentication failed" (HTTPS)

For push operations over HTTPS, you need a personal access token:
1. Generate token: https://github.com/settings/tokens
2. Use token as password when prompted
3. Or switch to SSH for easier authentication

### Want to Switch Back to HTTPS?

If SSH causes issues, you can always revert:

```bash
cd /path/to/GTMBA-Cruise_Logs
git remote set-url origin https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs.git
```

Note: You'll need a personal access token for push operations.

---

## Best Practices

### For End Users (Field Deployment)

- ✅ Use HTTPS installation
- ✅ No SSH setup needed
- ✅ Focus on using the application, not Git

### For Developers/Contributors

- ✅ Use HTTPS for initial install
- ✅ Set up SSH after installation
- ✅ Use SSH for all Git operations
- ✅ Keep SSH keys secure and backed up

### For System Administrators

- ✅ HTTPS install on all field computers
- ✅ SSH setup only on admin/development machines
- ✅ Document which machines have push access
- ✅ Use SSH for automated sync scripts

---

## Summary

| Feature | HTTPS | SSH |
|---------|-------|-----|
| **Initial install** | ✅ Easy | ⚠️ Requires setup |
| **Read access** | ✅ Works | ✅ Works |
| **Push access** | ⚠️ Needs token | ✅ Easy |
| **Authentication** | Password/Token | Key pair |
| **Firewall friendly** | ✅ Port 443 | ⚠️ Port 22 (may be blocked) |
| **Setup time** | 0 minutes | 5-10 minutes |

**Recommendation:** Start with HTTPS, upgrade to SSH when needed.

---

## Related Documentation

- **Windows Setup:** `windows/README.md`
- **macOS Setup:** `macos/SETUP_MACOS.md`
- **SSH Setup Script (Windows):** `windows/setup_github_ssh.ps1`
- **SSH Setup Script (macOS):** `macos/setup_github_ssh.sh`
- **GitHub SSH Guide:** https://docs.github.com/en/authentication/connecting-to-github-with-ssh

---

**Last Updated:** January 2025
