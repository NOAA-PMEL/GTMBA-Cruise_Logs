#!/usr/bin/env python
"""
Streamlit app to search the nylon inventory by spool ID
"""

import streamlit as st
import sqlite3
import pandas as pd
from config import DB_PATH

# Set page config
st.set_page_config(page_title="Nylon Inventory Search", layout="wide")

# Title
st.title("Nylon Lengths Inventory Search")

# Database connection
@st.cache_resource
def get_connection():
    return sqlite3.connect(DB_PATH, check_same_thread=False)

conn = get_connection()

# Search interface
st.subheader("Search by Spool ID")

search_term = st.text_input("Enter Spool ID:", "")

# Search button
if st.button("Search") or search_term:
    if search_term:
        # Query the database
        query = """
        SELECT * FROM nylon_inventory
        WHERE Spool_ID LIKE ?
        ORDER BY Spool_ID
        """

        try:
            df = pd.read_sql_query(query, conn, params=(f"%{search_term}%",))

            if len(df) > 0:
                st.success(f"Found {len(df)} result(s)")

                # Display results
                for idx, row in df.iterrows():
                    with st.expander(f"Spool ID: {row['Spool_ID']} - Length: {row['Length_m']}m"):
                        col1, col2 = st.columns(2)

                        with col1:
                            st.write("**Spool Information:**")
                            st.write(f"Spool ID: {row['Spool_ID']}")
                            st.write(f"Length: {row['Length_m']} meters")
                            st.write(f"Date: {row['Month']}/{row['Year']}")

                        with col2:
                            st.write("**Additional Details:**")
                            st.write(f"Lot Number: {row['Lot_Number']}")
                            st.write(f"EV50?: {row['Flag']}")

                        # Show all data in expandable section
                        with st.expander("View All Fields"):
                            st.write(row.to_dict())
            else:
                st.warning("No results found for that spool ID")
        except Exception as e:
            st.error(f"Error querying database: {e}")
    else:
        st.info("Please enter a spool ID to search")

# Show all records option
st.markdown("---")
if st.checkbox("Show All Inventory"):
    try:
        df_all = pd.read_sql_query(
            "SELECT Spool_ID, Month, Year, Length_m, Flag, Lot_Number FROM nylon_inventory ORDER BY Spool_ID",
            conn
        )
        st.dataframe(df_all, use_container_width=True)
        st.info(f"Total inventory items: {len(df_all)}")

        # Show some statistics
        st.subheader("Inventory Statistics")
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("Total Spools", len(df_all))
        with col2:
            # Convert to numeric, handling any non-numeric values
            total_length = pd.to_numeric(df_all['Length_m'], errors='coerce').sum()
            st.metric("Total Length", f"{total_length:,.0f} m")
        with col3:
            # Convert to numeric, handling any non-numeric values
            avg_length = pd.to_numeric(df_all['Length_m'], errors='coerce').mean()
            st.metric("Average Length", f"{avg_length:.1f} m")

    except Exception as e:
        st.error(f"Error loading inventory: {e}")
