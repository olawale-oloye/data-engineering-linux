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

