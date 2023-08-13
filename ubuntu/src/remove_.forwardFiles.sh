#!/usr/bin/env bash 

{ 
    perm_mask='0177' 
    valid_shells="^($( sed -rn '/^\//{s,/,\\\\/,g;p}' /etc/shells | paste -s - d '|' - ))$" 
    awk -v pat="$valid_shells" -F: '$(NF) ~ pat { print $1 " " $(NF-1) }' /etc/passwd | while read -r user home; do 
    if [ -f "$home/.forward" ]; then 
        echo -e "\n- User \"$user\" file: \"$home/.forward\" exists\n - removing file: \"$home/.forward\"\n"
        rm -f "$home/.forward" 
    fi 
done 
} 
