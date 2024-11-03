#!/bin/bash

# Directory to search in
SEARCH_DIR="/home"

# Find all .mp3 files and remove them
MP3_FILES=$(find "$SEARCH_DIR" -type f -name "*.mp3" 2>/dev/null)

# Check if any .mp3 files were found
if [ -n "$MP3_FILES" ]; then
    echo "The following MP3 files were found and will be removed:"
    echo "$MP3_FILES"
    echo
    # Prompt for confirmation with default to 'yes'
    read -p "Are you sure you want to delete these files? [Y/n] " CONFIRM
    if [[ -z "$CONFIRM" || "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
        # Remove the found .mp3 files
        find "$SEARCH_DIR" -type f -name "*.mp3" -exec rm -f {} \;
        echo "MP3 files have been removed."
    else
        echo "Operation cancelled. No files were removed."
    fi
else
    echo "No MP3 files were found."
fi

#Will be adding more file checks for passwords and stuff in the future, at the moment this is what I got