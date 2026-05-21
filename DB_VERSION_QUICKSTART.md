# Database Version Quick Reference

Quick commands for tracking and syncing the Cruise_Logs database.

## 📋 One-Time Setup

```bash
# Initialize version tracking (first time only)
python db_version.py --init

# Commit and push
git add Cruise_Logs.db db_version.py
git commit -m "Initialize database version tracking"
git push origin main
```

## 🌅 Start of Day

```bash
# Get latest database from GitHub
git pull origin main

# Check what version you have
python db_version.py --check
```

## 🌙 End of Day

```bash
# Update version with description of your work
python db_version.py --update "Added RB2501 cruise, 3 deployments, 2 recoveries"

# Commit and push to GitHub
git add Cruise_Logs.db
git commit -m "DB update: Added RB2501 cruise, 3 deployments, 2 recoveries"
git push origin main
```

## 🔍 Check Version Anytime

```bash
# Show version and sync status
python db_version.py --check
```

Example output:
```
============================================================
  CRUISE_LOGS DATABASE VERSION
============================================================
Version:        23
Last Modified:  2025-01-15 16:45:23
Modified By:    jsmith@FIELD-LAPTOP
Hostname:       FIELD-LAPTOP
Git Commit:     a3b5c2d
Description:    Added RB2501 cruise, 3 deployments
Record Count:   1547
============================================================

✓ Database is in sync with GitHub
```

## 🚨 Quick Help

```bash
# Show all available commands
python db_version.py --help
```

## 📊 Version Comparison

| Status | Meaning | Action Needed |
|--------|---------|---------------|
| ✓ In sync | Your DB matches GitHub | None - you're current |
| ⚠️ Local modifications | You have unsaved changes | Push to GitHub |
| ⬇️ Behind | GitHub has newer version | Pull from GitHub |

## 💡 Pro Tips

1. **Always pull before starting work** - Get the latest data first
2. **Update version when you push** - Track what changed
3. **Use descriptive messages** - "Added cruise X" not just "Update"
4. **Check version shows your hostname** - Know which laptop was used
5. **Record count helps verify** - Big change in count = lots of data added

## 🔗 Related Docs

- **Full Workflow Guide:** `DATABASE_SYNC_WORKFLOW.md`
- **Git Setup:** `GIT_SETUP.md`
- **Windows Setup:** `windows/README.md`
- **macOS Setup:** `macos/SETUP_MACOS.md`

---

**Remember:** GitHub = Master Copy. Sync daily. Track every update.
