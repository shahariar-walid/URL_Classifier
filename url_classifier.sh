#!/bin/bash


INPUT_FILE="wayback.txt"
OUTPUT_FILE_ACTIVE="active_urls.txt"
OUTPUT_FILE_INACTIVE="inactive_urls.txt"
OUTPUT_FILE_REDIRECT="redirect_urls.txt"

# Clear output files if they exist
> "$OUTPUT_FILE_ACTIVE"
> "$OUTPUT_FILE_INACTIVE"
> "$OUTPUT_FILE_REDIRECT"

# Function to check URL status
check_url() {
    url="$1"
    status_code=$(curl -I -s -o /dev/null -w "%{http_code}" "$url")
    
    if [[ "$status_code" =~ ^2 ]]; then
        echo "$url" >> "$OUTPUT_FILE_ACTIVE"
    elif [[ "$status_code" == "301" || "$status_code" == "302" ]]; then
        echo "$url" >> "$OUTPUT_FILE_REDIRECT"
    else
        echo "$url" >> "$OUTPUT_FILE_INACTIVE"
    fi
}

export -f check_url
export OUTPUT_FILE_ACTIVE
export OUTPUT_FILE_INACTIVE
export OUTPUT_FILE_REDIRECT

# Run checks in parallel using xargs
tr '\n' '\0' < "$INPUT_FILE" | xargs -0 -n 1 -P 20 -I {} bash -c 'check_url "{}"'

echo "Active URLs saved to $OUTPUT_FILE_ACTIVE"
echo "Redirect URLs saved to $OUTPUT_FILE_REDIRECT"
echo "Inactive URLs saved to $OUTPUT_FILE_INACTIVE"
