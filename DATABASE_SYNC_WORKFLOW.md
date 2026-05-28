# Database Sync Workflow

This guide explains how to keep the Cruise_Logs database synchronized across multiple field laptops using GitHub as the master repository.

## Overview

The database (`Cruise_Logs.db`) is tracked in Git and synchronized through GitHub. Each update to the database is versioned and tracked with metadata.

**Key Concept:** GitHub = Master Copy. All field laptops pull from and push to GitHub.

---

## Workflow

#### Pre-Cruise: Get Latest Database

Before starting work, pull the latest database from GitHub:


cd C:\Cruise_Logs  # Windows
# or
cd ~/NOAA-GitHub/GTMBA-Cruise_Logs  # macOS

# Pull latest changes
git pull origin main

# Check database version
python db_version.py --check

This ensures you have the most recent data before adding new records.

#### During the Cruise

Use the Cruise Logs application normally:
- Add cruise data
- Enter deployments
- Record recoveries
- Update repairs
- etc.

#### End of Cruise: Push Your Changes

After adding data, update the version and push to GitHub:

# Check what changed
python db_version.py --check

# Update version with description
python db_version.py --update "Added RB2501 cruise and 5 deployments"

# Commit and push
git add Cruise_Logs.db
git commit -m "DB v[X]: Added RB2501 cruise and 5 deployments"
git push origin main

---

## Version Management Commands

### Check Current Version


python db_version.py --check


Output:

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

# With description
python db_version.py --update "Description of changes"

# Without description (uses "Database update")
python db_version.py --update

**Remember:** GitHub is the master. Sync often. Use descriptive version messages.
