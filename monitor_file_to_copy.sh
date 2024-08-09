#!/bin/bash

echo


logger()
{
datenow=$(date "+%F %r")
echo -e "${datenow} ${1} ${2}"
echo -e "${datenow} ${1} ${2}" >> ${LOG_PATH_FILENAME}
}

UNIX_DDHHMM=`date '+%Y%m%d_%H%M%S'`
LOG_PATH_FILENAME="/path/logs/FILE_TRANSFER_LOG.LOG"
SOURCE_DIR="/path/source"

TARGET_HOST=`hostname -f`
logger "INFO" "TARGET_HOST:${TARGET_HOST}"
SLEEPER_INTERVAL_CHECK=600
SLEEPER_INTERVAL_GROWS=30

# List of file name patterns to monitor (date part will be dynamic)
PATTERNS=(
    "EQUITIES_TRADE_*.csv"
    "FX_TRADE_*.csv"
    "RATES_TRADE_*.csv"
    "CREDIT_TRADE_*.csv"
)

# Function to check if a file is stable (size doesn't change over a period of time)
is_file_stable() {
    local file="$1"
    local initial_size=$(stat -c%s "$file")
    sleep ${SLEEPER_INTERVAL_GROWS}  # Wait for 5 seconds
    local new_size=$(stat -c%s "$file")
    
    if [ "$initial_size" -eq "$new_size" ]; then
        return 0  # File is stable
    else
        return 1  # File is not stable
    fi
}

# Infinite loop to keep the script running
while true; do
    # Iterate over each file pattern
    for pattern in "${PATTERNS[@]}"; do
        matched_files=("$DIR"/$pattern)
        # Check if any files match the pattern
        if [[ -e "${matched_files[0]}" ]]; then
            for file in "${matched_files[@]}"; do
                
                # Exclude temporary files (_1.csv, _2.csv, etc.)
                if [[ "$file" =~ _[0-9]+\.csv$ ]]; then
                    continue  # Skip the temporary file
                fi
                # Check if the file exists, is not already renamed, and is a regular file
                if [[ -f "$file" && ! "$(basename "$file")" =~ ^done_ ]]; then
                    # Check if the file is stable
                    if is_file_stable "$file"; then
                        # Rename the file by adding the "done_" prefix
                        mv "$file" "$DIR/done_$(basename "$file")"
                        echo "Renamed $file to $DIR/done_$(basename "$file")"
                    fi
                fi
            done
        else
            echo "No files found for pattern: $pattern"
        fi
    done
    sleep 10  # Wait for 10 seconds before checking again
done
