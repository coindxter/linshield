#!/bin/bash

SEARCH_DIR="/home"

MP3_FILES=$(find "$SEARCH_DIR" -type f -name "*.mp3" 2>/dev/null)

if [ -n "$MP3_FILES" ]; then
    echo "The following MP3 files were found and will be removed:"
    echo "$MP3_FILES"
    echo
    read -p "Are you sure you want to delete these files? [Y/n] " CONFIRM
    if [[ -z "$CONFIRM" || "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
        find "$SEARCH_DIR" -type f -name "*.mp3" -exec rm -f {} \;
        echo "MP3 files have been removed."
    else
        echo "Operation cancelled. No files were removed."
    fi
else
    echo "No MP3 files were found."
fi

#Will be adding more file checks for passwords and stuff in the future, at the moment this is what I got