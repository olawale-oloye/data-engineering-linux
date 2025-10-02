# Succinct Data Pipeline using Bash Scripting

---
## Set Up the Environment
Make relevant directories (input, output, logs) <br>
`mkdir -p ~/data_pipeline/input ~/data_pipeline/output ~/data_pipeline/logs`

## Data Ingestion and Preprocessing
Create preprocess.sh using nano 
`touch preprocess.sh`

```
​#!/bin/bash

# Declare variables and path
LOG_DIR=~/home/olawaleoloye/data_pipeline/logs
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
```
> save on exit


Create monitor.sh using nano 
`touch preprocess.sh`
```
#!/bin/bash
# Declare Input and Output paths INPUT_FILE=~/home/olawaleoloye/data_pipeline/input/sales_data.csvOUTPUT_FILE=~/home/olawaleoloye/data_pipeline/output/cleaned_sales_data.csvLOG_FILE=~/Linux_LaunchPad/data_pipeline/logs/preprocess.log

# Check if input file existsif [[ ! -f "$INPUT_FILE" ]]; then echo "Input file not found: $INPUT_FILE" exit 1fi
# -f : flag checks if a file exists and it is a regular file

# Remove the extra_col (last col) and filter out rows with status=Failed
awk -F',' 'NR==1 { # remove last col header for (i=1; i<NF; i++) {printf "%s%s", $i, (i<NF-1?",":"\n")} next
}NR>1 && $NF !="Failed"{ for (i=1; i<NF; i++1) {printf "%s%s", $i, (i<NF-1?",":"\n")}}' "$INPUT_FILE" > "$OUTPUT_FILE"

#Log and sucesss message
echo "$(date '+%Y-%m-%d %H:%M:%S') - Processing completed! Output saved to $OUTPUT_FILE" >> "$LOG_FILE"echo "Preprocessing complete! Cleaned data saved to $OUTPUT_FILE"
```
> save on exit

Make scripts executable
`chmod +x /preprocess.sh /monitor.sh`

## Automate the Pipeline with Cron Jobs
On the terminal
Establish the server timezone / time 
`date`

Then  run `crontab -e`

```
# Set Locale
#CRON_TZ=Australia/Brisbane

​# ┌──────── min (0)
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

View active cron jobs
`crontab -l`
## Permissions and Security
Permissions 
`chmod 700 /input  /logs`
`chmod 755 /output`

Check current permissions
`ls -ld ~/data_pipeline/*`
`ls -l ~/preprocesssor.sh     ~/monitor.sh`









