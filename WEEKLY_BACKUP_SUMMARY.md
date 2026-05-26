# Weekly & Monthly Backup Configuration ✅

## Setup Complete!

Your Cruise_Logs database is now configured for **weekly and monthly backups only**, saving significant disk space.

## Backup Schedule

Your database will be automatically backed up:

- **Every Sunday at 2:00 AM** → Weekly backup
- **1st of each month at 2:00 AM** → Monthly backup

## Storage Summary

| Backup Type | Retention | Max Files | Storage |
|-------------|-----------|-----------|---------|
| Weekly      | 12 weeks  | ~11 files | ~330 MB |
| Monthly     | 12 months | 12 files  | ~360 MB |
| **TOTAL**   |           | **~23 files** | **~690 MB** |

**Total storage needed:** ~720 MB

## What Changed

### ✅ Removed
- Daily backup functionality (saves storage)

### ✅ Configured
- Weekly backups every Sunday
- Monthly backups on 1st of month
- Auto-cleanup of old backups
- Integrity verification on all backups

### ✅ Active
- Automated backup job installed and running
- Logging to `backup.log`

## Backup Locations

```
backups/
├── weekly/
│   └── (12 weeks of Sunday backups)
├── monthly/
│   └── (12 months of 1st-of-month backups)
├── latest_weekly.db → (symlink to most recent Sunday backup)
└── latest_monthly.db → (symlink to most recent monthly backup)
```

## Quick Commands

```bash
# Test backup manually
python backup_database.py

# List all backups
python backup_database.py --list

# Check backup log
tail -20 backup.log

# Verify backups
python backup_database.py --verify-only

# Restore from latest weekly backup
cp backups/latest_weekly.db Cruise_Logs.db

# Restore from latest monthly backup
cp backups/latest_monthly.db Cruise_Logs.db
```

## Monitoring

Check if the automated backup is running:
```bash
launchctl list | grep cruiselogs
```

View backup log:
```bash
tail -f backup.log
```

## Schedule Verification

To verify when the next backup will run, the job is configured to run:
- **Day 0 (Sunday)** at 02:00
- **Day 1 (1st of month)** at 02:00

## Next Backups

Based on today being Friday, May 16, 2026:
- **Next weekly backup:** Sunday, May 18, 2026 at 2:00 AM
- **Next monthly backup:** Sunday, June 1, 2026 at 2:00 AM

## How to Stop/Uninstall

If you ever need to stop the automated backups:

```bash
# Unload the job
launchctl unload ~/Library/LaunchAgents/gov.noaa.cruiselogs.backup.plist

# Remove the job file
rm ~/Library/LaunchAgents/gov.noaa.cruiselogs.backup.plist
```

## Timeline Example

Here's what your backup history will look like over time:

| Date | Type | Kept Until | File Count | Storage |
|------|------|------------|------------|---------|
| May 18 (Sun) | Weekly | August 10 | 1 | ~30 MB |
| May 25 (Sun) | Weekly | August 17 | 2 | ~60 MB |
| June 1 (Sun) | **Monthly** | June 1, 2027 | 3 | ~90 MB |
| June 8 (Sun) | Weekly | August 31 | 4 | ~120 MB |
| ... 3 months | ... | ... | ~14 | ~420 MB |
| ... 1 year | Stable | Rolling | ~23 | ~690 MB |

After 3 months, you'll have ~14 backups and ~420 MB used. After 1 year, it stabilizes at ~23 files.

## Coverage Analysis

Even with weekly/monthly backups, you have excellent data protection:

- **Last 12 weeks:** Can restore to any Sunday
- **Last 12 months:** Can restore to the 1st of any month
- **Maximum data loss:** Up to 6 days (worst case: backup on Sunday, issue on Saturday)

This is a good balance for most use cases, especially for a database that's primarily used for record-keeping rather than real-time transactions.

## If You Need More Frequent Backups

The current system provides weekly and monthly backups which should be sufficient for most needs. Weekly backups run automatically at 2 AM and are kept for 12 weeks.

## Configuration Files

- **Backup script:** `backup_database.py`
- **Setup script:** `setup_weekly_backup.sh`
- **Job file:** `~/Library/LaunchAgents/gov.noaa.cruiselogs.backup.plist`
- **Log file:** `backup.log`

## Status

✅ Daily backups: **NOT AVAILABLE**
✅ Weekly backups: **ENABLED** (Sundays at 2 AM)
✅ Monthly backups: **ENABLED** (1st of month at 2 AM)  
✅ Auto-cleanup: **ENABLED**  
✅ Integrity verification: **ENABLED**  
✅ Scheduled job: **ACTIVE**

Your database is protected with minimal disk space usage! 🎉
