# Database Backup Setup Guide

## Overview
The `backup_database.py` script provides automated, verified backups of your Cruise_Logs database with intelligent retention policies.

## Features
✅ **Automated backups** with cron scheduling  
✅ **Database integrity verification** before and after backup  
✅ **Smart retention policy**:
   - Weekly backups: kept for 12 weeks
   - Monthly backups: kept for 12 months (1st of month)  
✅ **Remote backup sync** via rsync  
✅ **Logging** to track all backup operations  
✅ **Quick access** to latest backups via symlinks

## Quick Start

### 1. Test Manual Backup
First, run a manual backup to ensure everything works:

```bash
cd /Users/lake/NOAA-GitHub/GTMBA-Cruise_Logs
python backup_database.py
```

You should see output confirming the backup was created and verified.

### 2. List Backups
```bash
python backup_database.py --list
```

### 3. Verify Existing Backups
```bash
python backup_database.py --verify-only
```

## Automated Backups (Recommended)

### Set Up Cron Job (macOS/Linux)

1. **Edit your crontab**:
   ```bash
   crontab -e
   ```

2. **Add one of these lines** (choose based on your needs):

   **Automated backup at 2 AM (local only):**
   ```cron
   0 2 * * * cd /Users/lake/NOAA-GitHub/GTMBA-Cruise_Logs && /usr/bin/python3 backup_database.py >> backup.log 2>&1
   ```

   **Automated backup at 2 AM with remote sync:**
   ```cron
   0 2 * * * cd /Users/lake/NOAA-GitHub/GTMBA-Cruise_Logs && /usr/bin/python3 backup_database.py --remote >> backup.log 2>&1
   ```

3. **Save and exit** (in vi/vim: press ESC, type `:wq`, press ENTER)

4. **Verify the cron job is installed**:
   ```bash
   crontab -l
   ```

### Alternative: Use launchd (macOS)

For more reliable scheduling on macOS, you can use launchd instead of cron.

1. **Create the plist file** (already provided as `setup_backup.sh`)

2. **Run the setup script**:
   ```bash
   chmod +x setup_backup.sh
   ./setup_backup.sh
   ```

This will create and load a launchd job that runs at 2 AM.

## Command Reference

### Basic Commands
```bash
# Create a backup now (auto-determines type based on date)
python backup_database.py

# Create a specific type of backup
python backup_database.py --type weekly
python backup_database.py --type monthly

# Create backup and sync to remote server
python backup_database.py --remote

# List all available backups
python backup_database.py --list

# Verify integrity of all backups
python backup_database.py --verify-only

# Clean up old backups (respects retention policy)
python backup_database.py --cleanup-only
```

## Backup Locations

Backups are stored in organized subdirectories:

```
backups/
├── weekly/
│   ├── Cruise_Logs_backup_20260518_020000.db
│   └── ...
├── monthly/
│   ├── Cruise_Logs_backup_20260501_020000.db
│   └── ...
├── latest_weekly.db → symlink to most recent weekly backup
└── latest_monthly.db → symlink to most recent monthly backup
```

## Retention Policy

The script automatically manages backup retention:

| Backup Type | Retention Period | Example: Backup on |
|-------------|------------------|-------------------|
| Weekly      | 12 weeks (84 days) | Most days |
| Monthly     | 12 months (360 days) | 1st of month |

Old backups are automatically deleted when you run the script.

## Remote Backup Configuration

To enable remote backups via rsync:

1. **Edit `config.py`** and update the `SYNC_CONFIG` section:
   ```python
   SYNC_CONFIG = {
       'remote_host': 'your-server.example.com',
       'remote_user': 'your-username',
       'remote_path': '/path/to/backup/directory/',
       'local_backup_dir': str(BASE_DIR / 'backups'),
   }
   ```

2. **Test remote sync**:
   ```bash
   python backup_database.py --remote
   ```

## Restoring from Backup

If you need to restore from a backup:

### Option 1: Replace Current Database
```bash
# CAUTION: This will overwrite your current database!
# Make sure to backup first if needed

cd /Users/lake/NOAA-GitHub/GTMBA-Cruise_Logs

# Copy a backup over the current database
cp backups/weekly/Cruise_Logs_backup_20260516_211205.db Cruise_Logs.db
```

### Option 2: Use Latest Backup
```bash
# Use the symlink to the latest backup
cp backups/latest_weekly.db Cruise_Logs.db
```

### Option 3: Test Backup First
```bash
# Verify backup is good before restoring
python backup_database.py --verify-only

# Check what's in the backup
sqlite3 backups/latest_weekly.db "SELECT COUNT(*) FROM deployments_normalized;"
```

## Monitoring Backups

### Check Backup Log
```bash
tail -f backup.log
```

### Check Cron Execution
On macOS, check system logs:
```bash
log show --predicate 'process == "cron"' --last 1d
```

### Get Email Notifications (Optional)
Add your email to the cron job:
```cron
MAILTO=your-email@noaa.gov
0 2 * * * cd /Users/lake/NOAA-GitHub/GTMBA-Cruise_Logs && /usr/bin/python3 backup_database.py --remote >> backup.log 2>&1
```

## Troubleshooting

### Backup Not Running Automatically
1. Check if cron service is running:
   ```bash
   sudo launchctl list | grep cron
   ```

2. Check crontab syntax:
   ```bash
   crontab -l
   ```

3. Check backup.log for errors:
   ```bash
   tail -50 backup.log
   ```

### Disk Space Issues
Check backup directory size:
```bash
du -sh backups/
```

Manually clean up old backups:
```bash
python backup_database.py --cleanup-only
```

### Permissions Issues
Ensure backup script is executable:
```bash
chmod +x backup_database.py
```

## Best Practices

1. **Test backups regularly** - Run verify-only monthly
2. **Monitor disk space** - Backups accumulate over time
3. **Test restoration** - Periodically verify you can restore from backup
4. **Keep remote backups** - Use `--remote` for off-site copies
5. **Check logs** - Review backup.log monthly for any warnings

## Security Notes

- Backups contain sensitive cruise data
- Ensure backup directory has proper permissions (700)
- Use encrypted connections for remote sync
- Store remote backups on NOAA-approved servers only

## Storage Requirements

Based on current database size (~30 MB):
- Weekly backups (12 weeks): ~360 MB
- Monthly backups (12 months): ~360 MB
- **Total storage needed**: ~720 MB

## Questions?

For issues or questions about the backup system, check:
1. `backup.log` - Detailed logging of all operations
2. `config.py` - Configuration settings
3. `backup_database.py` - Source code with comments
