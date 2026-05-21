# Database Sync Workflow

This guide explains how to keep the Cruise_Logs database synchronized across multiple field laptops using GitHub as the master repository.

## Overview

The database (`Cruise_Logs.db`) is tracked in Git and synchronized through GitHub. Each update to the database is versioned and tracked with metadata.

**Key Concept:** GitHub = Master Copy. All field laptops pull from and push to GitHub.

---

## Initial Setup (One Time)

### 1. Initialize Version Tracking

On your main machine (or first time setup):

```bash
cd /path/to/GTMBA-Cruise_Logs
python db_version.py --init
```

This creates a version tracking table inside the database with:
- Version number (starts at 1)
- Last modified timestamp
- Modified by (user@hostname)
- Git commit hash
- Description of changes
- Record count

### 2. Commit the Initialized Database

```bash
git add Cruise_Logs.db db_version.py
git commit -m "Initialize database version tracking"
git push origin main
```

---

## Daily Workflow

### Field Laptop Workflow

Each field laptop should follow this workflow:

#### Morning: Get Latest Database

Before starting work, pull the latest database from GitHub:

```bash
cd C:\Cruise_Logs  # Windows
# or
cd ~/Github/GTMBA-Cruise_Logs  # macOS

# Pull latest changes
git pull origin main

# Check database version
python db_version.py --check
```

This ensures you have the most recent data before adding new records.

#### During the Day: Work Normally

Use the Cruise Logs application normally:
- Add cruise data
- Enter deployments
- Record recoveries
- Update repairs
- etc.

#### End of Day: Push Your Changes

After adding data, update the version and push to GitHub:

```bash
# Check what changed
python db_version.py --check

# Update version with description
python db_version.py --update "Added RB2501 cruise and 5 deployments"

# Commit and push
git add Cruise_Logs.db
git commit -m "DB v[X]: Added RB2501 cruise and 5 deployments"
git push origin main
```

---

## Version Management Commands

### Check Current Version

```bash
python db_version.py --check
```

Output:
```
============================================================
  CRUISE_LOGS DATABASE VERSION
============================================================
Version:        15
Last Modified:  2025-01-15 16:45:23
Modified By:    jsmith@LAPTOP-FIELD01
Hostname:       LAPTOP-FIELD01
Git Commit:     a3b5c2d
Description:    Added RB2501 cruise and 5 deployments
Record Count:   1523
============================================================

✓ Database is in sync with GitHub
```

### Update Version

```bash
# With description
python db_version.py --update "Description of changes"

# Without description (uses "Database update")
python db_version.py --update
```

### Initialize (First Time Only)

```bash
python db_version.py --init
```

---

## Best Practices

### ✅ DO:

1. **Pull before you start work** - Always get latest from GitHub first
2. **Push at end of each day** - Share your updates with others
3. **Use descriptive version messages** - "Added 3 cruises from Jan 2025"
4. **Check version before pushing** - Make sure you know what changed
5. **Communicate with team** - Let others know about major updates

### ❌ DON'T:

1. **Don't work offline for days** - Sync at least daily
2. **Don't skip version updates** - Track every significant change
3. **Don't force push** - Resolve conflicts properly
4. **Don't edit database directly** - Always use the application forms

---

## Handling Merge Conflicts

SQLite databases can't be merged automatically. If you get a conflict:

### Option 1: Accept Remote (Safest)

```bash
# Keep GitHub version (lose your local changes)
git checkout origin/main Cruise_Logs.db
git pull origin main
```

⚠️ **Warning:** This discards your local changes!

### Option 2: Keep Local (Advanced)

```bash
# Keep your version (override GitHub)
git add Cruise_Logs.db
git commit -m "Keeping local database version"
git push origin main --force
```

⚠️ **Warning:** This overwrites other people's changes!

### Option 3: Manual Merge (Best but Complex)

1. Save your local database: `cp Cruise_Logs.db Cruise_Logs_local.db`
2. Pull remote: `git pull origin main`
3. Manually compare and merge data using SQL queries
4. Update version
5. Push merged database

**Prevention is better:** Sync daily to avoid conflicts!

---

## Multi-Laptop Scenario

### Scenario: Three Field Laptops

**Laptop A (Yours):**
- Morning: Pull latest (v14)
- Add data all day
- Evening: Update to v15, push

**Laptop B (Teammate):**
- Morning: Pull latest (v14)
- Add data all day
- Evening: Pull again (gets v15), update to v16, push

**Laptop C (Another teammate):**
- Morning: Pull latest (gets v16)
- Starts work with most recent data

### The Key: Sequential Updates

GitHub ensures everyone's updates are applied in order:
1. Everyone starts from same version
2. First person to push "wins" the next version number
3. Others pull, see changes, then add theirs on top
4. Versions increment: v14 → v15 → v16 → v17...

---

## Checking Sync Status

### Quick Status Check

```bash
python db_version.py --check
```

Shows:
- Current database version
- Who made last change
- Whether database needs to be pushed/pulled

### Git Status

```bash
git status Cruise_Logs.db
```

Possible outputs:
- **Nothing** = In sync ✓
- **Modified** = You have local changes to push ⚠️
- **Behind** = Need to pull updates from GitHub ⬇️

### Compare with GitHub

```bash
# Fetch latest from GitHub
git fetch origin

# Compare your version
git diff origin/main Cruise_Logs.db
```

---

## Automated Sync (Optional)

Create a batch file or script for easy syncing:

### Windows: `sync_database.bat`

```batch
@echo off
cd C:\Cruise_Logs

echo Checking database version...
python db_version.py --check

echo.
echo Pulling latest from GitHub...
git pull origin main

pause
```

### macOS: `sync_database.sh`

```bash
#!/bin/bash
cd ~/Github/GTMBA-Cruise_Logs

echo "Checking database version..."
python db_version.py --check

echo ""
echo "Pulling latest from GitHub..."
git pull origin main
```

---

## Version History

### View Version History

```bash
# See all database commits
git log --oneline Cruise_Logs.db

# See detailed changes
git log -p --stat Cruise_Logs.db
```

### View Specific Version

```bash
# Show version from specific commit
git show <commit-hash>:Cruise_Logs.db > old_version.db
```

### Rollback to Previous Version

```bash
# Find the commit you want
git log --oneline Cruise_Logs.db

# Restore that version
git checkout <commit-hash> Cruise_Logs.db

# Commit the rollback
git commit -m "Rollback database to version X"
git push origin main
```

---

## Troubleshooting

### "Database is locked"

Someone else is using it, or a process crashed:

```bash
# Check for running processes
# Windows:
tasklist | findstr python

# macOS:
ps aux | grep python

# Kill if needed, then try again
```

### "Push rejected - non-fast-forward"

Someone pushed while you were working:

```bash
# Pull their changes first
git pull origin main

# Then push yours
git push origin main
```

### "Version table doesn't exist"

Run initialization:

```bash
python db_version.py --init
```

### Database size is huge

Check for bloat:

```bash
# Compact database
sqlite3 Cruise_Logs.db "VACUUM;"

# Check size
# Windows:
dir Cruise_Logs.db

# macOS:
ls -lh Cruise_Logs.db
```

---

## Summary Checklist

### Daily Routine:

- [ ] **Morning:** `git pull origin main`
- [ ] **Morning:** `python db_version.py --check`
- [ ] **Work:** Enter data using application
- [ ] **Evening:** `python db_version.py --update "Description"`
- [ ] **Evening:** `git add Cruise_Logs.db`
- [ ] **Evening:** `git commit -m "DB vX: Description"`
- [ ] **Evening:** `git push origin main`

### Before Leaving on Cruise:

- [ ] Pull latest database
- [ ] Verify version is current
- [ ] Test all forms work
- [ ] Have backup copy on USB drive

### After Returning from Cruise:

- [ ] Update version with cruise summary
- [ ] Push all changes to GitHub
- [ ] Verify push succeeded
- [ ] Notify team of major updates

---

## Related Files

- `db_version.py` - Version management script
- `Cruise_Logs.db` - The database file
- `GIT_SETUP.md` - Git authentication setup
- `db_sync2.py` - Alternative sync tool (if using spectrum server)

---

**Remember:** GitHub is the master. Sync often. Use descriptive version messages. Communicate with your team!
