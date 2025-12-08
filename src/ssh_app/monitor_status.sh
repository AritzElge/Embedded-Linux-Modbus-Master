#!/bin/sh

# monitor_status.sh: Displays the system status on the console (stdout) with screen clearing.

STATUS_DIR="/tmp/status/"

# --- Function to get the highest error ---
get_highest_error() {
    HIGHEST_ERROR=0
    # Iterate over all .status files in the directory
    for status_file in "$STATUS_DIR"*.status; do
        if [ -f "$status_file" ]; then
            # Read the file content into a variable using a pipe and subshell
            CURRENT_ERROR=$(tr -d '\n' < "$status_file")
            
            # Compare and save the highest error
            if [ "$CURRENT_ERROR" -gt "$HIGHEST_ERROR" ]; then
                HIGHEST_ERROR="$CURRENT_ERROR"
            fi
        fi
    done
    echo "$HIGHEST_ERROR" # Return the highest error to stdout
}

# --- Main loop to display the information continuously ---
while true; do
    # 1. Clear the console screen (ANSI escape codes)
    # \033[2J clears the entire screen
    # \033[H moves the cursor to the top-left corner (Home)
    printf "\033[2J\033[H"

    # 2. Gather information
    DATE_STR=$(date +"Date: %d/%m/%Y")
    TIME_STR=$(date +"Time: %H:%M:%S")
    ERROR_CODE=$(get_highest_error)
    
    if [ "$ERROR_CODE" -eq 0 ]; then
        STATUS_LINE="Status: OK"
    else
        STATUS_LINE="Status: ERROR $ERROR_CODE"
    fi

    # 3. Display information to the console (stdout)
    echo "--------------------------------"
    echo "$DATE_STR"
    echo "$TIME_STR"
    echo "$STATUS_LINE"
    echo "--------------------------------"

    # 4. Wait 2 seconds before the next update
    sleep 2
    
    # No extra newline needed as the screen is cleared every loop
done
