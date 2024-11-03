# locate and remove MP3 files backup before deleting
MP3_FILES=$(locate -r '\.mp3$')
if [ "$MP3_FILES" != "" ]; then
    echo "The following MP3 files were found:"
    echo "$MP3_FILES"
    echo -n "Do you want to remove these files? (y/n) " && read REMOVE_MP3
    LOC="../backups/mp3_files.$(date +%Y-%m-%d)"
    if [ ! -d "$LOC" ]; then
        mkdir "$LOC"
    fi
    if [ "$REMOVE_MP3" == "y" ]; then
        sudo cp -r "$MP3_FILES" "$LOC"
        sudo rm -r "$MP3_FILES"
    else
        echo "Skipping MP3 files"
    fi
fi

#Will be adding more file checks for passwords and stuff in the future, at the moment this is what I got