# Repository Organization Guide

This document explains the organization of the Cruise_Logs repository, particularly the platform-specific documentation structure.

## 📁 Directory Structure

```
Cruise_Logs/
│
├── 📄 README.md                        # Main project documentation
├── 📄 INSTALLATION_GUIDE.md            # Installation guide for all platforms
├── 📄 requirements.txt                 # Python dependencies (cross-platform)
├── 📄 config.py                        # Cross-platform configuration module
├── 📄 verify_setup.py                  # Setup verification script (all platforms)
├── 📄 install_user.sh                  # Universal shell installer (Linux/macOS)
├── 📄 setup_backup.sh                  # Backup automation setup
├── 📄 .gitignore                       # Git ignore rules
├── 📄 .gitattributes                   # Git attributes configuration
│
├── 🗄️ Cruise_Logs.db                   # SQLite database
├── 📊 Equipment.xls                    # Acoustic releases data
├── 📊 NYLON LENGTHS_MostRecent.xls     # Nylon spools data
│
├── 🔄 Database Management
│   ├── db_version.py                   # Database version tracking
│   ├── db_sync2.py                     # Database synchronization utility
│   ├── backup_database.py              # Automated backup system
│   └── setup_backup.sh                 # Backup automation setup
│
├── 🚀 Launchers
│   ├── launcher.py                     # Cross-platform application launcher
│   └── admin_launcher.py               # Admin tools launcher
│
├── 📝 Application Files (Python/Streamlit)
│   ├── cruise_form.py                  # Main cruise information form
│   ├── dep_form_JSON.py                # Mooring deployment form
│   ├── rec_form_JSON.py                # Mooring recovery form
│   ├── repair_form_JSON.py             # Equipment repair form
│   ├── adcp_dep_form.py                # ADCP deployment form
│   ├── adcp_rec_form.py                # ADCP recovery form
│   ├── release_inventory_search.py     # Release inventory search
│   └── nylon_inventory_search.py       # Nylon inventory search
│
├── 🔄 Import Scripts
│   ├── import_release_inventory.py     # Import Equipment.xls
│   ├── import_nylon_inventory.py       # Import NYLON LENGTHS_MostRecent.xls
│   ├── import_dep.py                   # Import deployment XML
│   ├── import_rec.py                   # Import recovery XML
│   ├── import_repair.py                # Import repair XML
│   ├── import_adcp_dep.py              # Import ADCP deployment XML
│   └── import_adcp_rec.py              # Import ADCP recovery XML
│
├── 📖 General Documentation
│   ├── README_inventories.md           # Inventory systems overview
│   ├── README_release_inventory.md     # Release inventory details
│   ├── README_nylon_inventory.md       # Nylon inventory details
│   ├── BACKUP_QUICKSTART.txt           # Backup quick reference
│   ├── BACKUP_SETUP.md                 # Complete backup guide
│   ├── BACKUP_SUMMARY.md               # Backup system summary
│   ├── WEEKLY_BACKUP_SUMMARY.md        # Weekly backup configuration
│   ├── DB_VERSION_QUICKSTART.md        # Database version tracking guide
│   ├── DATABASE_SYNC_WORKFLOW.md       # Database sync workflow
│   └── LAUNCHER_README.md              # Launcher usage guide
│
├── 🍎 macos/                           # macOS-specific files
│   ├── README.md                       # macOS quick reference
│   ├── SETUP_MACOS.md                  # Complete macOS setup guide
│   └── install_user.sh                 # macOS automated installer
│
├── 🐧 linux/                           # Linux-specific files
│   ├── README.md                       # Linux quick reference
│   └── install_user.sh                 # Linux automated installer
│
├── 🪟 windows/                         # Windows-specific files
│   ├── README.md                       # Windows quick reference
│   ├── SETUP_WINDOWS.md                # Complete Windows setup guide
│   ├── WINDOWS_INSTALL_CHECKLIST.md   # Step-by-step checklist
│   ├── GITHUB_SETUP.md                 # Git repository setup
│   ├── environment_windows.yml         # Conda environment specification
│   ├── install.ps1                     # Automated Windows installer
│   └── run_cruise_form.bat             # Windows batch launcher
│
└── 📂 backups/                         # Backup directory (not in git)
    ├── weekly/                         # Weekly backups (Sundays, 12 weeks)
    ├── monthly/                        # Monthly backups (1st, 12 months)
    ├── latest_weekly.db                # Symlink to latest weekly
    └── latest_monthly.db               # Symlink to latest monthly
```

## 🎯 Platform-Specific Documentation

### macOS Users → [`macos/`](macos/)

**Files:**
- `install_user.sh` - Automated installation script (recommended)
- `SETUP_MACOS.md` - Complete installation guide for macOS
- `README.md` - Quick reference and overview

**Key Topics:**
- Automated installation with shell script
- Git setup (Xcode Command Line Tools or Homebrew)
- Anaconda or venv configuration
- Terminal aliases and shortcuts
- Automator app creation
- macOS-specific troubleshooting

**Quick Start (Automated):**
```bash
# Download and run installer
curl -O https://raw.githubusercontent.com/NOAA-PMEL/GTMBA-Cruise_Logs/main/macos/install_user.sh
bash install_user.sh
```

**Quick Start (Manual):**
```bash
cd ~/NOAA-GitHub
git clone https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs.git
cd GTMBA-Cruise_Logs
# Follow macos/SETUP_MACOS.md
```

### Linux Users → [`linux/`](linux/)

**Files:**
- `install_user.sh` - Automated installation script (recommended)
- `README.md` - Quick reference and overview

**Key Topics:**
- Automated installation with shell script
- Distribution-specific instructions (Ubuntu, Debian, Fedora, RHEL, CentOS, Arch)
- Git and Anaconda/Miniconda setup
- Shell script launchers
- Linux-specific troubleshooting

**Quick Start (Automated):**
```bash
# Download and run installer
curl -O https://raw.githubusercontent.com/NOAA-PMEL/GTMBA-Cruise_Logs/main/linux/install_user.sh
bash install_user.sh
```

### Windows Users → [`windows/`](windows/)

**Files:**
- `install.ps1` - Automated PowerShell installer (recommended)
- `SETUP_WINDOWS.md` - Complete installation guide for Windows
- `WINDOWS_INSTALL_CHECKLIST.md` - Interactive checklist format
- `GITHUB_SETUP.md` - Git repository setup and SSH configuration
- `environment_windows.yml` - Conda environment file
- `run_cruise_form.bat` - Batch file launcher
- `README.md` - Quick reference and overview

**Key Topics:**
- Anaconda installation on Windows
- Git setup for Windows
- Path configuration for `C:\Cruise_Logs`
- Desktop shortcuts
- Batch file usage
- Windows-specific troubleshooting

**Quick Start (Automated):**
```powershell
# Run the automated installer
powershell -ExecutionPolicy Bypass -File windows\install.ps1
```

**Quick Start (Manual):**
```powershell
# Clone manually:
git clone https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs.git
cd GTMBA-Cruise_Logs
# Follow windows/SETUP_WINDOWS.md
```

## 📚 Documentation Guide

### Where to Start?

1. **New to the system?** → Read main [`README.md`](README.md)
2. **Installing on any platform?** → See [`INSTALLATION_GUIDE.md`](INSTALLATION_GUIDE.md)
3. **Installing on macOS?** → Run [`macos/install_user.sh`](macos/install_user.sh) or see [`macos/SETUP_MACOS.md`](macos/SETUP_MACOS.md)
4. **Installing on Linux?** → Run [`linux/install_user.sh`](linux/install_user.sh) or see [`linux/README.md`](linux/README.md)
5. **Installing on Windows?** → Run [`windows/install.ps1`](windows/install.ps1) or go to [`windows/WINDOWS_INSTALL_CHECKLIST.md`](windows/WINDOWS_INSTALL_CHECKLIST.md)
6. **Setting up backups?** → See [`BACKUP_QUICKSTART.txt`](BACKUP_QUICKSTART.txt)
7. **Need inventory info?** → Read [`README_inventories.md`](README_inventories.md)
8. **Using the launcher?** → See [`LAUNCHER_README.md`](LAUNCHER_README.md)

### Documentation Hierarchy

```
Main README.md
    ├── INSTALLATION_GUIDE.md           # All platforms
    │   ├── install_user.sh             # Root-level universal installer
    │   ├── linux/install_user.sh       # Linux-specific
    │   ├── macos/install_user.sh       # macOS-specific
    │   └── windows/install.ps1         # Windows-specific
    │
    ├── Platform Setup Guides
    │   ├── linux/README.md
    │   ├── macos/SETUP_MACOS.md
    │   └── windows/SETUP_WINDOWS.md
    │       └── windows/WINDOWS_INSTALL_CHECKLIST.md
    │
    ├── Repository Setup
    │   └── windows/GITHUB_SETUP.md
    │
    └── Feature Documentation
        ├── README_inventories.md
        ├── README_release_inventory.md
        └── README_nylon_inventory.md
```

## 🔧 Cross-Platform Files

These files work on **both** macOS and Windows:

| File | Purpose |
|------|---------|
| `config.py` | Auto-detects OS and sets correct paths |
| `verify_setup.py` | Checks installation on any platform |
| `requirements.txt` | Python packages (platform-independent) |
| All `.py` application files | Run on any OS with Python |

## 🗂️ Why Separate Directories?

**Benefits of the `macos/` and `windows/` structure:**

1. **Clarity** - Clear separation of platform-specific instructions
2. **Organization** - Easier to find relevant documentation
3. **Maintenance** - Update one platform without affecting the other
4. **Scalability** - Easy to add Linux documentation later
5. **Clean Root** - Main directory stays uncluttered

## 📋 File Purpose Quick Reference

### Root Level Files

| Category | Files | Purpose |
|----------|-------|---------|
| **Database** | `Cruise_Logs.db` | Main SQLite database |
| **Data Sources** | `Equipment.xls`, `NYLON LENGTHS_MostRecent.xls` | Excel inventory data |
| **Forms** | `cruise_form.py`, `dep_form_JSON.py`, etc. | Streamlit web forms |
| **Search** | `*_inventory_search.py` | Inventory search applications |
| **Import** | `import_*.py` | Data import scripts |
| **Config** | `config.py`, `requirements.txt` | Configuration files |
| **Verification** | `verify_setup.py` | Setup checker |
| **Database Mgmt** | `db_version.py`, `db_sync2.py`, `backup_database.py` | Version, sync, backup |
| **Launchers** | `launcher.py`, `admin_launcher.py` | Application launchers |
| **Installation** | `install_user.sh` | Universal installer (Linux/macOS) |
| **Backup Setup** | `setup_backup.sh` | Automated backup configuration |
| **Git** | `.gitignore` | Git configuration |

### Linux Directory

| File | Purpose |
|------|---------||
| `install_user.sh` | Automated Linux installer script |
| `README.md` | Complete Linux installation guide |

### macOS Directory

| File | Purpose |
|------|---------||
| `install_user.sh` | Automated macOS installer script |
| `SETUP_MACOS.md` | Complete macOS installation guide |
| `README.md` | Quick start for macOS users |

### Windows Directory

| File | Purpose |
|------|---------||
| `install.ps1` | Automated Windows installer script |
| `SETUP_WINDOWS.md` | Complete Windows installation guide |
| `WINDOWS_INSTALL_CHECKLIST.md` | Step-by-step checklist |
| `GITHUB_SETUP.md` | Git and GitHub setup |
| `environment_windows.yml` | Conda environment file |
| `run_cruise_form.bat` | Batch launcher script |
| `README.md` | Quick start for Windows users |

### Backup Documentation

| File | Purpose |
|------|---------|
| `BACKUP_QUICKSTART.txt` | Quick reference for backup commands |
| `BACKUP_SETUP.md` | Complete backup system guide |
| `BACKUP_SUMMARY.md` | Backup system overview |
| `WEEKLY_BACKUP_SUMMARY.md` | Weekly backup configuration details |

## 🚀 Typical Workflows

### First-Time Setup (macOS)
1. Run `macos/install_user.sh` (automated)
   - Or read `macos/SETUP_MACOS.md` for manual setup
2. Repository is cloned to `~/Cruise_Logs`
3. Environment and packages installed automatically
4. Use launch scripts: `./start_cruise_logs.sh`

### First-Time Setup (Linux)
1. Run `linux/install_user.sh` (automated)
2. Repository is cloned to `~/Cruise_Logs`
3. Environment and packages installed automatically
4. Use launch scripts: `./start_cruise_logs.sh`

### First-Time Setup (Windows)
1. Run `windows/install.ps1` (automated)
   - Or read `windows/WINDOWS_INSTALL_CHECKLIST.md` for manual setup
2. Repository is cloned to user directory
3. Environment and packages installed automatically
4. Desktop shortcuts created automatically
5. Start using applications

### Daily Usage (Any Platform)
1. Use the launcher: `python launcher.py`
   - Or activate environment: `conda activate cruise_logs`
2. Navigate to repository
3. Run desired application: `streamlit run cruise_form.py`

### Updating Repository (Any Platform)
1. `git pull origin main`
2. `pip install --upgrade -r requirements.txt`

### Setting Up Backups (macOS/Linux)
1. Run: `./setup_backup.sh`
2. Backups run automatically:
   - Sundays at 2 AM (weekly, kept 12 weeks)
   - 1st of month at 2 AM (monthly, kept 12 months)

## 🔍 Finding What You Need

### "I need to install the system"
→ [`INSTALLATION_GUIDE.md`](INSTALLATION_GUIDE.md)

### "I need to install on Linux"
→ Run [`linux/install_user.sh`](linux/install_user.sh) or see [`linux/README.md`](linux/README.md)

### "I need to install on macOS"
→ Run [`macos/install_user.sh`](macos/install_user.sh) or see [`macos/SETUP_MACOS.md`](macos/SETUP_MACOS.md)

### "I need to install on Windows"
→ Run [`windows/install.ps1`](windows/install.ps1) or see [`windows/WINDOWS_INSTALL_CHECKLIST.md`](windows/WINDOWS_INSTALL_CHECKLIST.md)

### "How do I set up backups?"
→ [`BACKUP_QUICKSTART.txt`](BACKUP_QUICKSTART.txt) or [`BACKUP_SETUP.md`](BACKUP_SETUP.md)

### "What is this system?"
→ Main [`README.md`](README.md)

### "How do I search the inventory?"
→ [`README_inventories.md`](README_inventories.md)

### "Something isn't working"
→ Run `verify_setup.py` and check platform-specific SETUP guide

### "I want to use the launcher"
→ [`LAUNCHER_README.md`](LAUNCHER_README.md)

### "How do I track database versions?"
→ [`DB_VERSION_QUICKSTART.md`](DB_VERSION_QUICKSTART.md)

### "I want to create a shortcut (Windows)"
→ [`windows/SETUP_WINDOWS.md`](windows/SETUP_WINDOWS.md) - Section on shortcuts

### "I want to create an alias (macOS)"
→ [`macos/SETUP_MACOS.md`](macos/SETUP_MACOS.md) - Section on aliases

## 📦 What Gets Committed to Git?

### Tracked Files
- ✅ All `.py` Python files
- ✅ All `.md` documentation
- ✅ `requirements.txt`
- ✅ `config.py`
- ✅ `.gitignore`, `.gitattributes`
- ✅ `Cruise_Logs.db`
- ✅ Excel files (`.xls`)
- ✅ Conda environment files (`.yml`)
- ✅ Batch files (`.bat`)

### Ignored Files (see `.gitignore`)
- ❌ `__pycache__/`
- ❌ `*.pyc`
- ❌ Virtual environments (`venv/`, `env/`)
- ❌ OS files (`.DS_Store`, `Thumbs.db`)
- ❌ SQLite temporary files (`*.db-journal`)
- ❌ Excel temporary files (`~$*.xls`)
- ❌ Log files (`backup.log`, etc.)
- ❌ Backup files (`backups/` directory)
- ❌ Import staging (`imports/` directory)

## 🎓 Best Practices

1. **Use platform-specific docs** - Don't try to use Windows instructions on macOS
2. **Run verify_setup.py** - After installation and when troubleshooting
3. **Use config.py** - When writing new code, import from `config.py`
4. **Keep environments separate** - Use dedicated conda environment
5. **Read the README** - Each directory has a README with quick reference

## 🔄 Future Expansion

Potential additions to the structure:

```
Cruise_Logs/
├── linux/                     # ✅ Added: Linux documentation
│   ├── README.md              # ✅ Complete
│   └── install_user.sh        # ✅ Complete
├── docker/                    # Future: Docker configuration
│   ├── Dockerfile
│   └── docker-compose.yml
└── docs/                      # Future: Additional documentation
    ├── API.md
    ├── DATABASE_SCHEMA.md
    └── CONTRIBUTING.md
```

## 📞 Support

- **General questions** → See main `README.md`
- **Installation issues** → See platform-specific SETUP guide
- **Git/GitHub issues** → See `windows/GITHUB_SETUP.md`
- **Bugs or features** → Create GitHub issue
- **Verification** → Run `python verify_setup.py`

---

**Note on Authentication:** This repository uses HTTPS with 2FA (Google Authenticator) for GitHub authentication. SSH keys are not required.

---

**Last Updated:** May 2026
**Repository:** https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs