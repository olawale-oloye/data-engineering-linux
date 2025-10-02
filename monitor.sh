#!/bin/bash

# Declare variables and path
LOG_DIR=~/data_pipeline/logs
SUMMARY_LOG="$LOG_DIR/monitor_summary.log"


# Patterns to flag
PATTERN='ERROR|FAILED|EXCEPTION|FAIL|CRITICAL'


# Find matches (case-insensitive), include line numbers
ERRORS_FOUND=$(grep -Eirn "$PATTERN" "$LOG_DIR"/*log 2>/dev/null)

timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

if [[ -n "$ERRORS_FOUND" ]]; then 
  {
    echo "[$timestamp] Errors detected in pipeline logs: "
    echo "$ERRORS_FOUND"
    echo "======"
  } >> "$SUMMARY_LOG"


  # Also print to terminal if run manually
  echo "$ERRORS_FOUND"
else 
  echo "[$timestamp] No errors found." >> "$SUMMARY_LOG"

fi
