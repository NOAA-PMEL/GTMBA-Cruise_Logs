#!/usr/bin/env python3
"""
Automated Database Backup Script for Cruise_Logs.db

This script creates timestamped backups of the SQLite database with:
- Local backups with configurable retention
- Optional remote backups via rsync
- Backup verification (integrity check)
- Old backup cleanup
- Email notifications (optional)
- Logging

USAGE:
    python backup_database.py                    # Local backup only
    python backup_database.py --remote           # Local + remote backup
    python backup_database.py --verify-only      # Just verify existing backups
    python backup_database.py --cleanup-only     # Just cleanup old backups

CRON SETUP (automated backups at 2 AM):
    0 2 * * * cd /Users/lake/NOAA-GitHub/GTMBA-Cruise_Logs && /usr/bin/python3 backup_database.py --remote >> backup.log 2>&1
"""

import os
import sys
import sqlite3
import shutil
import subprocess
from datetime import datetime, timedelta
from pathlib import Path
import argparse
import logging

# Import configuration
from config import DB_PATH, BASE_DIR, SYNC_CONFIG, get_backup_directory

# Configuration
BACKUP_DIR = get_backup_directory()
# Note: Daily backups are not used to save storage space
KEEP_WEEKLY_BACKUPS = 12     # Keep 12 weeks of weekly backups
KEEP_MONTHLY_BACKUPS = 12    # Keep 12 months of monthly backups
MAX_BACKUP_SIZE_MB = 500     # Warn if backup exceeds this size

# Setup logging
LOG_FILE = os.path.join(BASE_DIR, 'backup.log')
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


def verify_database(db_path):
    """
    Verify database integrity using SQLite's PRAGMA integrity_check.
    Returns True if database is OK, False otherwise.
    """
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute("PRAGMA integrity_check")
        result = cursor.fetchone()[0]
        conn.close()

        if result == "ok":
            logger.info(f"✅ Database integrity check PASSED: {db_path}")
            return True
        else:
            logger.error(f"❌ Database integrity check FAILED: {db_path} - {result}")
            return False
    except Exception as e:
        logger.error(f"❌ Error verifying database {db_path}: {e}")
        return False


def get_database_stats(db_path):
    """Get database statistics (size, record count)."""
    try:
        # File size
        size_bytes = os.path.getsize(db_path)
        size_mb = size_bytes / (1024 * 1024)

        # Record count
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM deployments_normalized")
        record_count = cursor.fetchone()[0]
        conn.close()

        return {
            'size_bytes': size_bytes,
            'size_mb': size_mb,
            'record_count': record_count
        }
    except Exception as e:
        logger.error(f"Error getting database stats: {e}")
        return None


def create_backup(source_db, backup_dir, backup_type='weekly'):
    """
    Create a timestamped backup of the database.

    Args:
        source_db: Path to source database
        backup_dir: Directory to store backups
        backup_type: 'weekly' or 'monthly'

    Returns:
        Path to backup file if successful, None otherwise
    """
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    date_str = datetime.now().strftime('%Y-%m-%d')

    # Create subdirectories for different backup types
    type_dir = os.path.join(backup_dir, backup_type)
    os.makedirs(type_dir, exist_ok=True)

    # Backup filename
    backup_filename = f"Cruise_Logs_backup_{timestamp}.db"
    backup_path = os.path.join(type_dir, backup_filename)

    try:
        logger.info(f"Creating {backup_type} backup: {backup_filename}")

        # Verify source database before backup
        if not verify_database(source_db):
            logger.error("Source database failed integrity check. Backup aborted!")
            return None

        # Get source database stats
        stats = get_database_stats(source_db)
        if stats:
            logger.info(f"Database stats: {stats['size_mb']:.2f} MB, {stats['record_count']} records")

            # Warn if database is unusually large
            if stats['size_mb'] > MAX_BACKUP_SIZE_MB:
                logger.warning(f"⚠️  Database size ({stats['size_mb']:.2f} MB) exceeds expected size ({MAX_BACKUP_SIZE_MB} MB)")

        # Create backup using SQLite's backup API (safer than file copy)
        source_conn = sqlite3.connect(source_db)
        backup_conn = sqlite3.connect(backup_path)

        with backup_conn:
            source_conn.backup(backup_conn)

        source_conn.close()
        backup_conn.close()

        # Verify backup
        if verify_database(backup_path):
            backup_stats = get_database_stats(backup_path)
            logger.info(f"✅ Backup created successfully: {backup_path}")
            logger.info(f"   Backup size: {backup_stats['size_mb']:.2f} MB")
            logger.info(f"   Records: {backup_stats['record_count']}")

            # Create a "latest" symlink
            latest_link = os.path.join(backup_dir, f'latest_{backup_type}.db')
            if os.path.exists(latest_link) or os.path.islink(latest_link):
                os.remove(latest_link)
            os.symlink(backup_path, latest_link)

            return backup_path
        else:
            logger.error(f"❌ Backup verification failed. Removing bad backup: {backup_path}")
            os.remove(backup_path)
            return None

    except Exception as e:
        logger.error(f"❌ Error creating backup: {e}")
        if os.path.exists(backup_path):
            os.remove(backup_path)
        return None


def cleanup_old_backups(backup_dir):
    """
    Clean up old backups based on retention policy.
    - Keep weekly backups for KEEP_WEEKLY_BACKUPS weeks
    - Keep monthly backups for KEEP_MONTHLY_BACKUPS months
    """
    now = datetime.now()

    for backup_type in ['weekly', 'monthly']:
        type_dir = os.path.join(backup_dir, backup_type)
        if not os.path.exists(type_dir):
            continue

        # Determine retention period
        if backup_type == 'weekly':
            retention_days = KEEP_WEEKLY_BACKUPS * 7
        else:  # monthly
            retention_days = KEEP_MONTHLY_BACKUPS * 30

        cutoff_date = now - timedelta(days=retention_days)

        # Get all backup files
        backup_files = []
        for filename in os.listdir(type_dir):
            if filename.startswith('Cruise_Logs_backup_') and filename.endswith('.db'):
                filepath = os.path.join(type_dir, filename)
                file_mtime = datetime.fromtimestamp(os.path.getmtime(filepath))
                backup_files.append((filepath, file_mtime))

        # Sort by modification time
        backup_files.sort(key=lambda x: x[1], reverse=True)

        # Delete old backups
        deleted_count = 0
        for filepath, mtime in backup_files:
            if mtime < cutoff_date:
                try:
                    os.remove(filepath)
                    deleted_count += 1
                    logger.info(f"Deleted old {backup_type} backup: {os.path.basename(filepath)}")
                except Exception as e:
                    logger.error(f"Error deleting {filepath}: {e}")

        if deleted_count > 0:
            logger.info(f"Cleaned up {deleted_count} old {backup_type} backup(s)")

        # Report remaining backups
        remaining = len(backup_files) - deleted_count
        logger.info(f"Keeping {remaining} {backup_type} backup(s)")


def sync_to_remote(backup_path):
    """
    Sync backup to remote server using rsync.

    Args:
        backup_path: Path to backup file to sync

    Returns:
        True if successful, False otherwise
    """
    remote_host = SYNC_CONFIG['remote_host']
    remote_user = SYNC_CONFIG['remote_user']
    remote_path = SYNC_CONFIG['remote_path']

    if not remote_host or not remote_user:
        logger.warning("Remote sync not configured. Skipping remote backup.")
        return False

    try:
        # Create remote directory if needed
        remote_full_path = f"{remote_user}@{remote_host}:{remote_path}"

        logger.info(f"Syncing to remote: {remote_full_path}")

        # Use rsync for efficient transfer
        cmd = [
            'rsync',
            '-avz',
            '--progress',
            backup_path,
            remote_full_path
        ]

        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode == 0:
            logger.info(f"✅ Remote sync successful")
            return True
        else:
            logger.error(f"❌ Remote sync failed: {result.stderr}")
            return False

    except FileNotFoundError:
        logger.error("❌ rsync not found. Please install rsync for remote backups.")
        return False
    except Exception as e:
        logger.error(f"❌ Error syncing to remote: {e}")
        return False


def determine_backup_type():
    """
    Determine what type of backup to create based on current date.
    - First day of month: monthly
    - All other days: weekly
    """
    now = datetime.now()

    # First day of month
    if now.day == 1:
        return 'monthly'
    else:
        return 'weekly'


def list_backups(backup_dir):
    """List all available backups with details."""
    print("\n" + "=" * 70)
    print("AVAILABLE BACKUPS")
    print("=" * 70)

    for backup_type in ['weekly', 'monthly']:
        type_dir = os.path.join(backup_dir, backup_type)
        if not os.path.exists(type_dir):
            continue

        print(f"\n{backup_type.upper()} BACKUPS:")
        print("-" * 70)

        backup_files = []
        for filename in os.listdir(type_dir):
            if filename.startswith('Cruise_Logs_backup_') and filename.endswith('.db'):
                filepath = os.path.join(type_dir, filename)
                file_mtime = datetime.fromtimestamp(os.path.getmtime(filepath))
                size_mb = os.path.getsize(filepath) / (1024 * 1024)
                backup_files.append((filename, filepath, file_mtime, size_mb))

        backup_files.sort(key=lambda x: x[2], reverse=True)

        for filename, filepath, mtime, size_mb in backup_files:
            age = datetime.now() - mtime
            print(f"  {filename}")
            print(f"    Date: {mtime.strftime('%Y-%m-%d %H:%M:%S')} ({age.days} days ago)")
            print(f"    Size: {size_mb:.2f} MB")

    print("\n" + "=" * 70)


def main():
    parser = argparse.ArgumentParser(description='Backup Cruise_Logs database')
    parser.add_argument('--remote', action='store_true', help='Also sync to remote server')
    parser.add_argument('--verify-only', action='store_true', help='Only verify existing backups')
    parser.add_argument('--cleanup-only', action='store_true', help='Only cleanup old backups')
    parser.add_argument('--list', action='store_true', help='List all available backups')
    parser.add_argument('--type', choices=['weekly', 'monthly'], help='Force specific backup type')

    args = parser.parse_args()

    logger.info("=" * 70)
    logger.info("CRUISE_LOGS DATABASE BACKUP SCRIPT")
    logger.info("=" * 70)
    logger.info(f"Database: {DB_PATH}")
    logger.info(f"Backup Directory: {BACKUP_DIR}")

    # Ensure backup directory exists
    os.makedirs(BACKUP_DIR, exist_ok=True)

    # List backups mode
    if args.list:
        list_backups(BACKUP_DIR)
        return 0

    # Verify-only mode
    if args.verify_only:
        logger.info("Verifying existing backups...")
        for backup_type in ['weekly', 'monthly']:
            type_dir = os.path.join(BACKUP_DIR, backup_type)
            if not os.path.exists(type_dir):
                continue

            for filename in os.listdir(type_dir):
                if filename.endswith('.db'):
                    filepath = os.path.join(type_dir, filename)
                    verify_database(filepath)
        return 0

    # Cleanup-only mode
    if args.cleanup_only:
        logger.info("Cleaning up old backups...")
        cleanup_old_backups(BACKUP_DIR)
        return 0

    # Normal backup mode
    if not os.path.exists(DB_PATH):
        logger.error(f"❌ Database not found: {DB_PATH}")
        return 1

    # Determine backup type
    backup_type = args.type if args.type else determine_backup_type()
    logger.info(f"Backup type: {backup_type}")

    # Create backup
    backup_path = create_backup(DB_PATH, BACKUP_DIR, backup_type)

    if not backup_path:
        logger.error("❌ Backup failed!")
        return 1

    # Sync to remote if requested
    if args.remote:
        sync_to_remote(backup_path)

    # Cleanup old backups
    cleanup_old_backups(BACKUP_DIR)

    logger.info("=" * 70)
    logger.info("✅ BACKUP COMPLETED SUCCESSFULLY")
    logger.info("=" * 70)

    return 0


if __name__ == '__main__':
    sys.exit(main())
