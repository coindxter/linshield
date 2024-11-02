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

# locate any files containg passwords
PASSWORD_FILES=$(grep -r -l -i "password" /)
if [ "$PASSWORD_FILES" != "" ]; then
    echo "The following files contain the word password:"
    echo "$PASSWORD_FILES"
    echo -n "Do you want to remove these files? (y/n) " && read REMOVE_PASSWORD
    LOC="../backups/password_files.$(date +%Y-%m-%d)"
    if [ ! -d "$LOC" ]; then
        mkdir "$LOC"
    fi
    if [ "$REMOVE_PASSWORD" == "y" ]; then
        sudo cp -r "$PASSWORD_FILES" "$LOC"
        sudo rm -r "$PASSWORD_FILES"
    else
        echo "Skipping password files"
    fi
fi

# locate any files containing password hashs
PASSWORD_HASH_FILES = $(grep -r -E '(^\$[156]\$|^[0-9a-f]{32,64}$)' /)
if [ "$PASSWORD_HASH_FILES" != "" ]; then
    echo "The following files contain the word password_hash:"
    echo "$PASSWORD_HASH_FILES"
    echo -n "Do you want to remove these files? (y/n) " && read REMOVE_PASSWORD_HASH
    LOC="../backups/password_hash_files.$(date +%Y-%m-%d)"
    if [ ! -d "$LOC" ]; then
        mkdir "$LOC"
    fi
    if [ "$REMOVE_PASSWORD_HASH" == "y" ]; then
        sudo cp -r "$PASSWORD_HASH_FILES" "$LOC"
        sudo rm -r "$PASSWORD_HASH_FILES"
    else
        echo "Skipping password_hash files"
    fi
fi

# locate any files containing credit card numbers
CREDIT_CARD_FILES=$(grep -r -E '[0-9]{13,16}' /)
if [ "$CREDIT_CARD_FILES" != "" ]; then
    echo "The following files contain the word credit_card:"
    echo "$CREDIT_CARD_FILES"
    echo -n "Do you want to remove these files? (y/n) " && read REMOVE_CREDIT_CARD
    LOC="../backups/credit_card_files.$(date +%Y-%m-%d)"
    if [ ! -d "$LOC" ]; then
        mkdir "$LOC"
    fi
    if [ "$REMOVE_CREDIT_CARD" == "y" ]; then
        sudo cp -r "$CREDIT_CARD_FILES" "$LOC"
        sudo rm -r "$CREDIT_CARD_FILES"
    else
        echo "Skipping credit_card files"
    fi
fi

# locate any files containing phone numbers
PHONE_NUMBER_FILES=$(grep -r -E '[0-9]{10,11}' /)
if [ "$PHONE_NUMBER_FILES" != "" ]; then
    echo "The following files contain the word phone_number:"
    echo "$PHONE_NUMBER_FILES"
    echo -n "Do you want to remove these files? (y/n) " && read REMOVE_PHONE_NUMBER
    LOC="../backups/phone_number_files.$(date +%Y-%m-%d)"
    if [ ! -d "$LOC" ]; then
        mkdir "$LOC"
    fi
    if [ "$REMOVE_PHONE_NUMBER" == "y" ]; then
        sudo cp -r "$PHONE_NUMBER_FILES" "$LOC"
        sudo rm -r "$PHONE_NUMBER_FILES"
    else
        echo "Skipping phone_number files"
    fi
fi