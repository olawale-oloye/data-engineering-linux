#!/bin/bash

# ====================================================
#  Preprocess Script: Download, Clean, and Log Events
# ====================================================

# Define directories and files
BASE_DIR=~/data_pipeline
INPUT_DIR=$BASE_DIR/input
OUTPUT_DIR=$BASE_DIR/output
LOG_DIR=$BASE_DIR/logs

INPUT_FILE=$INPUT_DIR/sales_data.csv
OUTPUT_FILE=$OUTPUT_DIR/cleaned_sales_data.csv
LOG_FILE=$LOG_DIR/preprocess.log

# Create directories if they don't exist
mkdir -p "$INPUT_DIR" "$OUTPUT_DIR" "$LOG_DIR"

# Start logging
echo "=============================================" >> "$LOG_FILE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Pipeline started" >> "$LOG_FILE"

# Step 1: Data Ingestion
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting data ingestion..." >> "$LOG_FILE"

if curl -L -o "$INPUT_FILE" https://raw.githubusercontent.com/dataengineering-community/launchpad/refs/heads/main/Linux/sales_data.csv; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Data successfully downloaded to $INPUT_FILE" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: Failed to download sales_data.csv" >> "$LOG_FILE"
    echo "Failed to download data. Check internet connection or URL."
    exit 1
fi

# Step 2: Validate input file
echo "$(date '+%Y-%m-%d %H:%M:%S') - Validating input file..." >> "$LOG_FILE"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: Input file not found at $INPUT_FILE" >> "$LOG_FILE"
    echo "Input file not found."
    exit 1
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Input file exists. Proceeding to cleaning stage." >> "$LOG_FILE"
fi

# Step 3: Data Cleaning
echo "$(date '+%Y-%m-%d %H:%M:%S') - Cleaning data (removing 'extra_col' and filtering 'Failed' rows)..." >> "$LOG_FILE"

if awk -F',' '
NR==1 {
    for (i=1; i<NF; i++) {
        printf "%s%s", $i, (i<NF-1 ? "," : "\n")
    }
    next
}
NR>1 && $6 != "Failed" {
    for (i=1; i<NF; i++) {
        printf "%s%s", $i, (i<NF-1 ? "," : "\n")
    }
}
' "$INPUT_FILE" > "$OUTPUT_FILE"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Data cleaning successful. Cleaned file saved to $OUTPUT_FILE" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: Data cleaning failed during AWK processing." >> "$LOG_FILE"
    echo "Data cleaning failed."
    exit 1
fi

# Step 4: Secure the pipeline directories
echo "$(date '+%Y-%m-%d %H:%M:%S') - Securing directories..." >> "$LOG_FILE"
chmod 700 "$INPUT_DIR" "$LOG_DIR"
chmod 600 "$LOG_DIR"/*.log
echo "$(date '+%Y-%m-%d %H:%M:%S') - Permissions set (input/logs restricted)" >> "$LOG_FILE"

# Step 5: Finish
echo "$(date '+%Y-%m-%d %H:%M:%S') - Pipeline completed successfully" >> "$LOG_FILE"
echo "Preprocessing complete! Cleaned data saved to $OUTPUT_FILE"
echo "=============================================" >> "$LOG_FILE"

