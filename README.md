Succinct Data Pipeline using Bash Scripting
---
## As a data engineer, was tasked to set up a data processing pipeline using Linux commands and bash scripts. This project would cover file manipulation, automation, permissions management, scheduling with cron, and logging.
---
### Create directories for organizing the pipeline:
~/data_pipeline/input
~/data_pipeline/output
~/data_pipeline/logs

### Permissions and Security
Adjust permissions to secure files and directories:
Set the input folder to be writable only by your user.
Restrict access to logs so only authorized users can read them.

Create preprocess.sh using nano <br>
`touch preprocess.sh`

```

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

```
> save on exit


Create monitor.sh using nano <br>
`touch monitor.sh`

```

#!/bin/bash

# ====================================================
#   Monitor Script: Scan Logs for Errors and Summarize
# ====================================================

# Declare directories and file paths
LOG_DIR=~/data_pipeline/logs
SUMMARY_LOG="$LOG_DIR/monitor_summary.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Start a new section in the summary log
timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================================" >> "$SUMMARY_LOG"
echo "[$timestamp] - Monitoring started" >> "$SUMMARY_LOG"

# Patterns to look for (case-insensitive)
PATTERN='ERROR|FAILED|EXCEPTION|FAIL|CRITICAL'

# Find matches (case-insensitive), include file name and line number
ERRORS_FOUND=$(grep -Eirn "$PATTERN" "$LOG_DIR"/*.log 2>/dev/null)

if [[ -n "$ERRORS_FOUND" ]]; then
  ERROR_COUNT=$(echo "$ERRORS_FOUND" | wc -l)
  {
    echo "[$timestamp] Errors detected in pipeline logs!"
    echo "[$timestamp] Total matches: $ERROR_COUNT"
    echo "------------------"
    echo "$ERRORS_FOUND"
    echo "------------------"
    echo "[$timestamp] End of error report."
    echo
  } >> "$SUMMARY_LOG"

  # Also print to terminal (for manual runs)
  echo "$ERROR_COUNT potential errors found:"
  echo "$ERRORS_FOUND"
  exit 1
else
  echo "[$timestamp] No errors found in logs." >> "$SUMMARY_LOG"
  echo "No errors found in logs."
  exit 0
fi


```
> save on exit

Make scripts executable <br>
`chmod +x /preprocess.sh /monitor.sh`

## Automate the Pipeline with Cron Jobs
On the terminal
Establish the server timezone / time 
`date`

Then  run `crontab -e`

```

# Set Locale
#CRON_TZ=Australia/Brisbane

# ┌──────── min (0)
# │ ┌────── hour (0 = midnight)
# │ │ ┌──── day of month (* = every)
# │ │ │ ┌── month (* = every)
# │ │ │ │ ┌─ day of week (* = every)
# │ │ │ │ │
# * * * * *

# Run preprocessing every day at 12:00am
0 0 * * * /home/olawaleoloye/data_pipeline/preprocess.sh >> /home/olawaleoloye/data_pipeline/logs/preprocessor_cron.log 2>&1

# Run monitor 5 minutes later
5 0 * * * /home/olawaleoloye/data_pipeline/monitor.sh

```

View active cron jobs <br>
`crontab -l`

## Permissions and Security
Permissions 
`chmod 700 /input  /logs`
`chmod 755 /output`

Check current permissions <br>
`ls -ld ~/data_pipeline/*`
`ls -l ~/preprocesssor.sh     ~/monitor.sh`









