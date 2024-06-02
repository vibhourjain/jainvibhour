#!/bin/bash

# Directory to monitor
DIR="/today/input"

# List of file name patterns to monitor (date part will be dynamic)
PATTERNS=(
    "test1_*.csv"
    "test2_*.csv"
    "test3_*.csv"
    "test4_*.csv"
    "test5_*.csv"
    "test6_*.csv"
)

# Function to check if a file is stable (size doesn't change over a period of time)
is_file_stable() {
    local file="$1"
    local initial_size=$(stat -c%s "$file")
    sleep 5  # Wait for 5 seconds
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
        # Find all files matching the current pattern
        matched_files=("$DIR"/"$pattern")

        # Check if any files match the pattern
        if [[ ${#matched_files[@]} -gt 0 && -e "${matched_files[0]}" ]]; then
            for file in "${matched_files[@]}"; do
                # Check if the file exists, is not already renamed, and is a regular file
                if [[ -f "$file" && ! "$(basename "$file")" =~ ^done_ ]]; then
                    # Check if the file is stable
                    if is_file_stable "$file"; then
                        # Rename the file by adding the "done_" prefix
                        mv "$file" "$DIR/done_$(basename "$file")"
                        echo "Renamed $file to $DIR/done_$(basename "$file")"
                    else
                        echo "File $file is not stable yet."
                    fi
                else
                    echo "File $file is either already renamed or not a regular file."
                fi
            done
        else
            echo "No files found for pattern: $pattern"
        fi
    done
    sleep 10  # Wait for 10 seconds before checking again
done
