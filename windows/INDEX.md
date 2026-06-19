# Windows Installation Files - Quick Index

**All Windows installation files are now organized in this directory!**

---

## 🚀 Getting Started

### For Office Users / Individual Installation
**→ Start here:** [QUICKSTART_USER.md](QUICKSTART_USER.md)

**Quick install:**
```powershell
# Double-click this file:
INSTALL_USER.bat

# OR run in PowerShell:
powershell -ExecutionPolicy Bypass -File install_user.ps1
```

### For Field Laptops / Shared Computers
**→ Start here:** [README.md](README.md) (scroll to "Quick Install")

**Quick install:**
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

---

## 📁 File Directory

### Installation Scripts
| File | Purpose |
|------|---------|
| `install.ps1` | Field laptop installer (C:\Cruise_Logs) |
| `install_user.ps1` | User installer (C:\Users\YourName\Cruise_Logs) |
| `INSTALL_USER.bat` | Easy launcher for user installer |

### Documentation
| File | Purpose |
|------|---------|
| `QUICKSTART_USER.md` | Complete user installation guide |
| `INSTALL_INSTRUCTIONS_USER.txt` | One-page printable instructions |
| `USER_INSTALLATION_FILES.md` | Overview of user installation system |
| `README.md` | Complete Windows setup guide (all methods) |
| `INSTALL_COMMAND.txt` | Legacy installation commands |
| `FIELD_DEPLOYMENT_GUIDE.md` | Field deployment procedures |

### Configuration
| File | Purpose |
|------|---------|
| `environment_windows.yml` | Conda environment specification |

---

## 🤔 Which Installation Should I Use?

```
┌─────────────────────────────────────────────┐
│  Do you have admin rights on this computer? │
└─────────────────┬───────────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
        YES               NO
         │                 │
         ▼                 ▼
┌─────────────────┐  ┌──────────────────┐
│ Is this a       │  │ Use USER install │
│ shared field    │  │ install_user.ps1 │
│ laptop?         │  └──────────────────┘
└────────┬────────┘
         │
    ┌────┴─────┐
   YES        NO
    │          │
    ▼          ▼
┌────────┐  ┌────────┐
│ FIELD  │  │ USER   │
│ install│  │ install│
└────────┘  └────────┘
```

**User Installation** (`install_user.ps1`)
- ✅ No admin needed
- ✅ Installs to your user folder
- ✅ Won't affect other users
- ✅ Best for: Office work, managers, individual use

**Field Installation** (`install.ps1`)
- ⚙️ Admin recommended
- ⚙️ Installs to C:\Cruise_Logs
- ⚙️ Shared by all users
- ⚙️ Best for: Field laptops, shared equipment

---

## 📊 Installation Comparison

| Feature | User Install | Field Install |
|---------|-------------|---------------|
| **Script** | `install_user.ps1` | `install.ps1` |
| **Location** | `C:\Users\YourName\Cruise_Logs` | `C:\Cruise_Logs` |
| **Admin Rights** | ❌ Not needed | ✅ Recommended |
| **Shared Machine** | Each user gets own copy | Single shared copy |
| **Best For** | Office users, managers | Field technicians |
| **Desktop Shortcuts** | ✅ Yes | ✅ Yes |

---

## 🆘 Quick Help

### I just want to install Cruise Logs
→ Read [QUICKSTART_USER.md](QUICKSTART_USER.md)  
→ Run `INSTALL_USER.bat`

### I need to set up a field laptop
→ Read [README.md](README.md)  
→ Run `install.ps1`

### I want printable instructions
→ Print [INSTALL_INSTRUCTIONS_USER.txt](INSTALL_INSTRUCTIONS_USER.txt)

### Something went wrong
→ Check [QUICKSTART_USER.md](QUICKSTART_USER.md) → Troubleshooting section  
→ Check [README.md](README.md) → Troubleshooting section

### I need more info about the files
→ Read [USER_INSTALLATION_FILES.md](USER_INSTALLATION_FILES.md)

---

## 🔧 Prerequisites

Before running any installer, make sure you have:

1. **Anaconda** or **Miniconda**
   - Download: https://www.anaconda.com/download/
   - Choose "Just Me" during installation

2. **Git**
   - Download: https://git-scm.com/download/win
   - Use default settings during installation

---

## 📞 Getting Help

- **User Guide:** [QUICKSTART_USER.md](QUICKSTART_USER.md)
- **Full Windows Guide:** [README.md](README.md)
- **GitHub Issues:** https://github.com/NOAA-PMEL/GTMBA-Cruise_Logs/issues
- **Main Project README:** [../README.md](../README.md)

---

**Last Updated:** June 2026  
**Maintained By:** NOAA PMEL GTMBA Team
