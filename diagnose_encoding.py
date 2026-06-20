"""
Diagnostic script to check for encoding issues in the Cruise Logs database
Run this to identify any character encoding problems on Windows
"""

import sqlite3
import sys
from config import DB_PATH

print("=" * 60)
print("Cruise Logs Encoding Diagnostic")
print("=" * 60)
print(f"Python version: {sys.version}")
print(f"Default encoding: {sys.getdefaultencoding()}")
print(f"File system encoding: {sys.getfilesystemencoding()}")
print(f"Database path: {DB_PATH}")
print("=" * 60)
print()

try:
    # Connect to database
    conn = sqlite3.connect(DB_PATH)
    conn.text_factory = str  # Ensure strings are returned as str
    cursor = conn.cursor()

    # Get list of tables
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    print(f"Found {len(tables)} tables:")
    for table in tables:
        print(f"  - {table[0]}")
    print()

    # Check the cruises table
    print("Checking 'cruises' table for encoding issues...")
    print("-" * 60)

    cursor.execute("SELECT COUNT(*) FROM cruises")
    count = cursor.fetchone()[0]
    print(f"Total cruises: {count}")
    print()

    # Get column names
    cursor.execute("PRAGMA table_info(cruises)")
    columns = cursor.fetchall()
    column_names = [col[1] for col in columns]
    print(f"Columns ({len(column_names)}):")
    for col in column_names:
        print(f"  - {col}")
    print()

    # Check for non-ASCII characters in text fields
    print("Scanning for non-ASCII characters...")
    print("-" * 60)

    text_columns = ['Cruise', 'Vessel', 'Personnel', 'Comments', 'Purpose']
    issues_found = False

    for col in text_columns:
        if col not in column_names:
            continue

        cursor.execute(f"SELECT id, {col} FROM cruises WHERE {col} IS NOT NULL")
        rows = cursor.fetchall()

        for row_id, value in rows:
            if value:
                # Check for non-ASCII characters
                try:
                    value.encode('ascii')
                except (UnicodeEncodeError, AttributeError) as e:
                    issues_found = True
                    # Find the problematic characters
                    non_ascii_chars = [c for c in str(value) if ord(c) > 127]
                    if non_ascii_chars:
                        print(f"\nRow ID {row_id}, Column '{col}':")
                        print(f"  Value: {repr(value)[:100]}")
                        print(f"  Non-ASCII chars: {non_ascii_chars}")
                        print(f"  Char codes: {[hex(ord(c)) for c in non_ascii_chars]}")

    if not issues_found:
        print("✓ No non-ASCII character encoding issues found!")
    print()

    # Test reading data as pandas would
    print("Testing pandas DataFrame reading...")
    print("-" * 60)
    try:
        import pandas as pd
        df = pd.read_sql_query("SELECT * FROM cruises LIMIT 10", conn)
        print(f"✓ Successfully read {len(df)} rows into pandas DataFrame")
        print(f"  Columns: {list(df.columns)[:5]}...")
        print()

        # Check for any problematic values
        for col in df.columns:
            if df[col].dtype == 'object':  # String columns
                for idx, val in enumerate(df[col]):
                    if pd.notna(val) and val:
                        try:
                            str(val).encode('utf-8')
                        except Exception as e:
                            print(f"! Encoding issue in column '{col}', row {idx}: {e}")
                            issues_found = True

        if not issues_found:
            print("✓ All data can be encoded to UTF-8")

    except Exception as e:
        print(f"✗ Error reading with pandas: {e}")
        import traceback
        traceback.print_exc()

    conn.close()

    print()
    print("=" * 60)
    print("Diagnostic Complete")
    print("=" * 60)

except Exception as e:
    print(f"\n✗ Error during diagnostic: {e}")
    import traceback
    traceback.print_exc()
