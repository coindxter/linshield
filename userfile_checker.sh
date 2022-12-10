!/bin/bash

# Iterate through all the users on the system
for user in $(cut -d: -f1 /etc/passwd); do
  # Check if the user's home directory exists
  if [ -d "/home/$user" ]; then
    # Print the user's name
    echo "User: $user"
    # Go through all the files and directories in the user's home directory
    for item in /home/$user/*; do
      # Check if the item is a directory
      if [ -d $item ]; then
        # Go through all the files in the directory
        for file in $item/*; do
          # Print the name of the file
          echo " - $(basename $file)"
        done
      # If the item is not a directory, print its name
      else
        echo " - $(basename $item)"
      fi
    done
  fi
done


