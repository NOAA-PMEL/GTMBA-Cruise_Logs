"""
DEBUG VERSION of cruise_form.py
Use this to identify where errors occur
"""
import os
import sqlite3
import sys
import traceback
from datetime import date, datetime

import pandas as pd
import streamlit as st
from config import DB_PATH

print("=" * 60)
print("DEBUG: Starting cruise_form_debug.py")
print(f"Python: {sys.version}")
print(f"Platform: {sys.platform}")
print(f"Encoding: {sys.getdefaultencoding()}")
print(f"DB Path: {DB_PATH}")
print("=" * 60)

# Page configuration
try:
    st.set_page_config(page_title="GTMBA Cruise Information", page_icon="🚢", layout="wide")
    print("✓ Page config set successfully")
except Exception as e:
    print(f"✗ Error setting page config: {e}")
    traceback.print_exc()

# Database connection
def get_connection():
    """Create a database connection with UTF-8 support"""
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.text_factory = lambda x: x.decode('utf-8', errors='replace') if isinstance(x, bytes) else x
        print("✓ Database connection created")
        return conn
    except Exception as e:
        print(f"✗ Error creating database connection: {e}")
        traceback.print_exc()
        raise

def get_cruise_data():
    """Get all cruise data"""
    try:
        conn = get_connection()
        query = """
        SELECT
            id,
            Beginning_Date as 'Beginning Date',
            Cruise,
            Ending_Date as 'Ending Date',
            Leg,
            Lines,
            Personnel,
            Port1,
            Port2,
            Port3,
            Ship
        FROM Cruise_Info
        ORDER BY Beginning_Date DESC
        """
        print(f"✓ Executing query...")
        df = pd.read_sql_query(query, conn)
        print(f"✓ Retrieved {len(df)} cruise records")
        conn.close()
        return df
    except Exception as e:
        print(f"✗ Error getting cruise data: {e}")
        traceback.print_exc()
        st.error(f"Database error: {e}")
        return pd.DataFrame()

# Main app
try:
    st.title("🚢 GTMBA Cruise Information")
    print("✓ Title displayed")

    st.markdown("""
    View and search cruise information from the GTMBA database.
    """)
    print("✓ Markdown displayed")

    # Get data
    print("Getting cruise data...")
    df = get_cruise_data()
    print(f"Data retrieved: {len(df)} rows")

    if df.empty:
        st.warning("No cruise data available")
        print("✗ No data in DataFrame")
    else:
        # Display results
        message = f"Found {len(df)} cruises"
        print(f"Displaying: {message}")
        st.subheader(message)
        print("✓ Subheader displayed")

        # Show first few rows
        st.dataframe(df.head(10), use_container_width=True, hide_index=True)
        print("✓ Dataframe displayed")

        st.success("✓ Application loaded successfully!")
        print("✓ Success message displayed")

except Exception as e:
    error_msg = f"ERROR in main app: {e}"
    print(error_msg)
    traceback.print_exc()
    st.error(error_msg)
    st.code(traceback.format_exc())

print("=" * 60)
print("DEBUG: Script execution complete")
print("=" * 60)
