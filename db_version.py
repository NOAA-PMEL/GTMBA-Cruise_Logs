#!/usr/bin/env python
"""
Database Version Tracking for Cruise_Logs
Tracks database version, last update, and sync status
"""

import sqlite3
import os
import sys
import socket
import subprocess
from datetime import datetime
from pathlib import Path

# Database path
DB_PATH = os.path.join(os.path.dirname(__file__), "Cruise_Logs.db")


def init_version_table():
    """Initialize the database version tracking table"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Create version table if it doesn't exist
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS db_version (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            version_number INTEGER NOT NULL DEFAULT 1,
            last_modified TIMESTAMP NOT NULL,
            modified_by TEXT NOT NULL,
            hostname TEXT NOT NULL,
            git_commit TEXT,
            description TEXT,
            record_count INTEGER
        )
    """)

    # Check if we have a version record
    cursor.execute("SELECT COUNT(*) FROM db_version")
    count = cursor.fetchone()[0]

    if count == 0:
        # Initialize version record
        hostname = socket.gethostname()
        username = os.getenv('USERNAME') or os.getenv('USER') or 'unknown'
        modified_by = f"{username}@{hostname}"

        # Get git commit if available
        git_commit = get_git_commit()

        # Count total records across main tables
        record_count = count_all_records(cursor)

        cursor.execute("""
            INSERT INTO db_version (
                id, version_number, last_modified, modified_by,
                hostname, git_commit, description, record_count
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            1, 1, datetime.now(), modified_by,
            hostname, git_commit, "Initial version", record_count
        ))

        print("✓ Database version table initialized")
    else:
        print("✓ Database version table already exists")

    conn.commit()
    conn.close()


def get_git_commit():
    """Get current git commit hash"""
    try:
        result = subprocess.run(
            ['git', 'rev-parse', '--short', 'HEAD'],
            cwd=os.path.dirname(__file__),
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except:
        pass
    return None


def count_all_records(cursor):
    """Count total records across all main tables"""
    tables = ['cruise', 'deployment', 'recovery', 'repair', 'adcp_deployment', 'adcp_recovery']
    total = 0

    for table in tables:
        try:
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            total += cursor.fetchone()[0]
        except:
            pass

    return total


def get_version():
    """Get current database version information"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT version_number, last_modified, modified_by,
                   hostname, git_commit, description, record_count
            FROM db_version WHERE id = 1
        """)
        result = cursor.fetchone()

        if result:
            return {
                'version': result[0],
                'last_modified': result[1],
                'modified_by': result[2],
                'hostname': result[3],
                'git_commit': result[4],
                'description': result[5],
                'record_count': result[6]
            }
    except sqlite3.OperationalError:
        # Table doesn't exist yet
        return None
    finally:
        conn.close()

    return None


def update_version(description="Database update"):
    """Increment version and update metadata"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    hostname = socket.gethostname()
    username = os.getenv('USERNAME') or os.getenv('USER') or 'unknown'
    modified_by = f"{username}@{hostname}"
    git_commit = get_git_commit()
    record_count = count_all_records(cursor)

    cursor.execute("""
        UPDATE db_version SET
            version_number = version_number + 1,
            last_modified = ?,
            modified_by = ?,
            hostname = ?,
            git_commit = ?,
            description = ?,
            record_count = ?
        WHERE id = 1
    """, (datetime.now(), modified_by, hostname, git_commit, description, record_count))

    conn.commit()

    # Get new version
    cursor.execute("SELECT version_number FROM db_version WHERE id = 1")
    new_version = cursor.fetchone()[0]

    conn.close()

    return new_version


def display_version():
    """Display current database version"""
    version_info = get_version()

    if not version_info:
        print("❌ Database version table not initialized")
        print("Run: python db_version.py --init")
        return

    print("\n" + "="*60)
    print("  CRUISE_LOGS DATABASE VERSION")
    print("="*60)
    print(f"Version:        {version_info['version']}")
    print(f"Last Modified:  {version_info['last_modified']}")
    print(f"Modified By:    {version_info['modified_by']}")
    print(f"Hostname:       {version_info['hostname']}")
    print(f"Git Commit:     {version_info['git_commit'] or 'N/A'}")
    print(f"Description:    {version_info['description']}")
    print(f"Record Count:   {version_info['record_count']}")
    print("="*60 + "\n")


def check_sync_status():
    """Check if database needs to be pushed/pulled from GitHub"""
    try:
        # Check git status
        result = subprocess.run(
            ['git', 'status', '--porcelain', 'Cruise_Logs.db'],
            cwd=os.path.dirname(__file__),
            capture_output=True,
            text=True,
            timeout=5
        )

        if result.returncode == 0:
            output = result.stdout.strip()

            if not output:
                print("✓ Database is in sync with GitHub")
                return True
            elif output.startswith('M'):
                print("⚠️  Database has local modifications - needs to be pushed")
                return False
            else:
                print(f"⚠️  Database status: {output}")
                return False
    except:
        print("❓ Could not check Git status")

    return None


def main():
    """Main entry point"""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--init':
            init_version_table()
        elif sys.argv[1] == '--update':
            description = sys.argv[2] if len(sys.argv) > 2 else "Database update"
            new_version = update_version(description)
            print(f"✓ Database version updated to v{new_version}")
            print(f"  Description: {description}")
        elif sys.argv[1] == '--check':
            display_version()
            check_sync_status()
        elif sys.argv[1] == '--help':
            print("""
Database Version Management

Usage:
  python db_version.py --init              Initialize version tracking
  python db_version.py --check             Show current version and sync status
  python db_version.py --update [desc]     Increment version with description
  python db_version.py --help              Show this help

Examples:
  python db_version.py --init
  python db_version.py --check
  python db_version.py --update "Added cruise RB2501 data"
            """)
        else:
            print(f"Unknown option: {sys.argv[1]}")
            print("Use --help for usage information")
    else:
        # Default: show version
        display_version()


if __name__ == '__main__':
    main()
