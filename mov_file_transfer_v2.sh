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
ADDITIONAL_DIR="/path/additional_source"  # Add the new directory here
DEST_BASE_DIR="/gmr"  # Base directory for moving files

TARGET_HOST=`hostname -f`
logger "INFO" "TARGET_HOST:${TARGET_HOST}"
SLEEPER_INTERVAL_CHECK=600
SLEEPER_INTERVAL_GROWS=30

# List of file name patterns to monitor
PATTERNS=(
    "EQUITIES1_TRADE_20??????.csv"
    "EQUITIES2_TRADE_20??????.csv"
    "EQUITIES3_TRADE_20??????.csv"
    "EQUITIES4_TRADE_20??????.csv"
    "EQUITIES5_TRADE_20??????.csv"
    "EQUITIES6_TRADE_20??????.csv"
)

# Additional patterns for the other directory
ADDITIONAL_PATTERNS=(
    "FX_TRADE_20??-??-??_V1.csv"  # Add the actual pattern for the additional file
)

# Function to extract date from file name and move it to the destination directory
move_file_to_dest() {
    local file="$1"
    local dest_dir="$2"

    # Extract the date portion from the file name
    if [[ "$file" =~ ([0-9]{8}) ]]; then
        date_part="${BASH_REMATCH[1]}"
    elif [[ "$file" =~ ([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
        date_part="${BASH_REMATCH[0]//-/}"
    else
        logger "ERROR" "Could not extract date from file: $file"
        return 1
    fi

    # Create the destination directory based on the date
    dest_path="$dest_dir/$date_part"
    mkdir -p "$dest_path"

    # Move the file to the destination directory
    mv "$file" "$dest_path/$(basename "$file")"
    logger "INFO" "Moved $file to $dest_path/$(basename "$file")"
}

# Function to check if a file is stable (size doesn't change over a period of time)
is_file_stable() {
    local file="$1"
    local initial_size=$(stat -c%s "$file")
    sleep ${SLEEPER_INTERVAL_GROWS}  # Wait for the defined interval
    local new_size=$(stat -c%s "$file")
    
    if [ "$initial_size" -eq "$new_size" ]; then
        return 0  # File is stable
    else
        return 1  # File is not stable
    fi
}

# Function to process files in a given directory with specific patterns
process_files() {
    local dir="$1"
    shift
    local patterns=("$@")

    for pattern in "${patterns[@]}"; do
        matched_files=("$dir"/$pattern)
        if [[ -e "${matched_files[0]}" ]]; then
            for file in "${matched_files[@]}"; do
                # Only process files without a numeric suffix
                if [[ "$file" =~ _[0-9]+\.csv$ ]]; then
                    continue  # Skip the temporary file with numeric suffix
                fi

                if [[ -f "$file" && ! "$(basename "$file")" =~ ^done_ ]]; then
                    if is_file_stable "$file"; then
                        move_file_to_dest "$file" "$DEST_BASE_DIR"
                    fi
                fi
            done
        else
            logger "INFO" "No files found for pattern: $pattern in directory: $dir"
        fi
    done
}

# Infinite loop to keep the script running
while true; do
    # Process files in the main source directory
    process_files "$SOURCE_DIR" "${PATTERNS[@]}"

    # Process files in the additional directory
    process_files "$ADDITIONAL_DIR" "${ADDITIONAL_PATTERNS[@]}"

    # Sleep for the specified interval before checking again
    sleep ${SLEEPER_INTERVAL_CHECK}
done
