#!/bin/bash
#
# Setup script for automated database backups
# This creates a launchd job (macOS) or cron job (Linux) for automated backups
#

set -e

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DB_PATH="${SCRIPT_DIR}/Cruise_Logs.db"
BACKUP_SCRIPT="${SCRIPT_DIR}/backup_database.py"

echo "========================================"
echo "Cruise_Logs Database Backup Setup"
echo "Weekly (Sundays) and Monthly Backups"
echo "========================================"
echo ""
echo "Script directory: $SCRIPT_DIR"
echo "Database: $DB_PATH"
echo "Backup script: $BACKUP_SCRIPT"
echo ""

# Check if database exists
if [ ! -f "$DB_PATH" ]; then
    echo "❌ Error: Database not found at $DB_PATH"
    exit 1
fi

# Check if backup script exists
if [ ! -f "$BACKUP_SCRIPT" ]; then
    echo "❌ Error: Backup script not found at $BACKUP_SCRIPT"
    exit 1
fi

# Make backup script executable
chmod +x "$BACKUP_SCRIPT"

# Detect OS
OS=$(uname -s)

if [ "$OS" == "Darwin" ]; then
    echo "Detected macOS - setting up launchd job"
    echo ""

    # Create launchd plist file
    PLIST_FILE="$HOME/Library/LaunchAgents/gov.noaa.cruiselogs.backup.plist"

    cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>gov.noaa.cruiselogs.backup</string>

    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>${BACKUP_SCRIPT}</string>
    </array>

    <key>WorkingDirectory</key>
    <string>${SCRIPT_DIR}</string>

    <key>StartCalendarInterval</key>
    <array>
        <!-- Weekly: Every Sunday at 2 AM -->
        <dict>
            <key>Weekday</key>
            <integer>0</integer>
            <key>Hour</key>
            <integer>2</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
        <!-- Monthly: 1st of month at 2 AM -->
        <dict>
            <key>Day</key>
            <integer>1</integer>
            <key>Hour</key>
            <integer>2</integer>
            <key>Minute</key>
            <integer>0</integer>
        </dict>
    </array>

    <key>StandardOutPath</key>
    <string>${SCRIPT_DIR}/backup.log</string>

    <key>StandardErrorPath</key>
    <string>${SCRIPT_DIR}/backup.log</string>

    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
EOF

    echo "✅ Created launchd plist: $PLIST_FILE"

    # Load the launchd job
    launchctl unload "$PLIST_FILE" 2>/dev/null || true
    launchctl load "$PLIST_FILE"

    echo "✅ Loaded launchd job"
    echo ""
    echo "Backups will run:"
    echo "  - Every Sunday at 2:00 AM (weekly)"
    echo "  - 1st of each month at 2:00 AM (monthly)"
    echo ""
    echo "To check status:"
    echo "  launchctl list | grep cruiselogs"
    echo ""
    echo "To uninstall:"
    echo "  launchctl unload ~/Library/LaunchAgents/gov.noaa.cruiselogs.backup.plist"
    echo "  rm ~/Library/LaunchAgents/gov.noaa.cruiselogs.backup.plist"

elif [ "$OS" == "Linux" ]; then
    echo "Detected Linux - setting up cron jobs"
    echo ""

    # Remove old cron job if exists
    if crontab -l 2>/dev/null | grep -q "backup_database.py"; then
        echo "⚠️  Removing old cron jobs..."
        crontab -l 2>/dev/null | grep -v "backup_database.py" | crontab -
    fi

    # Add weekly backup (Sunday at 2 AM)
    WEEKLY_ENTRY="0 2 * * 0 cd ${SCRIPT_DIR} && /usr/bin/python3 ${BACKUP_SCRIPT} >> ${SCRIPT_DIR}/backup.log 2>&1"
    # Add monthly backup (1st of month at 2 AM)
    MONTHLY_ENTRY="0 2 1 * * cd ${SCRIPT_DIR} && /usr/bin/python3 ${BACKUP_SCRIPT} >> ${SCRIPT_DIR}/backup.log 2>&1"

    # Add both cron jobs
    (crontab -l 2>/dev/null; echo "$WEEKLY_ENTRY"; echo "$MONTHLY_ENTRY") | crontab -

    echo "✅ Added cron jobs"
    echo ""
    echo "Backups will run:"
    echo "  - Every Sunday at 2:00 AM (weekly)"
    echo "  - 1st of each month at 2:00 AM (monthly)"
    echo ""
    echo "To check cron jobs:"
    echo "  crontab -l"
    echo ""
    echo "To uninstall:"
    echo "  crontab -e  # then remove the backup_database.py line"

else
    echo "❌ Unsupported operating system: $OS"
    exit 1
fi

echo ""
echo "========================================"
echo "Testing backup now..."
echo "========================================"
echo ""

# Run backup once to test
python3 "$BACKUP_SCRIPT"

echo ""
echo "✅ Setup complete!"
echo ""
echo "Backups will be stored in: ${SCRIPT_DIR}/backups/"
echo "Logs will be written to: ${SCRIPT_DIR}/backup.log"
echo ""
echo "To test the backup manually:"
echo "  python3 ${BACKUP_SCRIPT}"
echo ""
echo "To list backups:"
echo "  python3 ${BACKUP_SCRIPT} --list"
echo ""
