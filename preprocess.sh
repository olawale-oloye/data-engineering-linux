#!/bin/bash

curl -L -o "sales_data.csv" https://raw.githubusercontent.com/dataengineering-community/launchpad/refs/heads/main/Linux/sales_data.csv
mv ~/data_pipeline/sales_data.csv ~/data_pipeline/input/sales_data.csv


# Declare Input and Output paths 
INPUT_FILE=~/data_pipeline/input/sales_data.csv
OUTPUT_FILE=~/data_pipeline/output/cleaned_sales_data.csv
LOG_FILE=~/data_pipeline/logs/preprocess.log



# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
       	echo "Input file not found: $INPUT_FILE" 
	exit 1
fi


# -f : flag checks if a file exists and it is a regular file

# Remove the extra_col (last col) and filter out rows with status=Failed
awk -F',' 'NR==1 { 
	# remove last col header 
	for (i=1; i<NF; i++) {printf "%s%s", $i, (i<NF-1?",":"\n")} 
	next
}
NR>1 && $NF !="Failed"{ 
	for (i=1; i<NF; i++) {printf "%s%s", $i, (i<NF-1?",":"\n")}
}' "$INPUT_FILE" > "$OUTPUT_FILE"

#Log and sucesss message
echo "$(date '+%Y-%m-%d %H:%M:%S') - Processing completed! Output saved to $OUTPUT_FILE" >> "$LOG_FILE"
echo "Preprocessing complete! Cleaned data saved to $OUTPUT_FILE"
