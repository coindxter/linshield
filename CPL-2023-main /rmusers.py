#!/usr/bin/env python3

import os
import subprocess
import sys

# Get the data directory path either from the environment variable or command-line argument
data_dir = os.getenv("DATA") or sys.argv[1]

# Define the file paths
authorized_users_file = os.path.join(data_dir, "authorized_users")
existing_users_file = os.path.join(data_dir, "existing_users")
unauthed_file = os.path.join(data_dir, "unauthorized_users")

# Read the authorized users from the file
authorized_users = []
with open(authorized_users_file, "r") as f:
    authorized_users = [user.strip() for user in f if user.strip()]

# Read the existing users from the file
existing_users = []
with open(existing_users_file, "r") as f:
    existing_users = [user.strip() for user in f if user.strip()]

# Open the file to write unauthorized users
with open(unauthed_file, "w") as f:
    # Loop through existing users
    for user in existing_users:
        # Check if the user is not in the list of authorized users
        if user not in authorized_users:
            # Remove the unauthorized user
            subprocess.call(['deluser', "--remove-home", user])
            # Write the unauthorized user to the file
            f.write(user + "\n")
            # Print a message indicating that the user has been removed
            print(f"User {user} removed")
        else:
            # Update password aging settings for authorized users
            subprocess.call(['chage', '-M90', '-m1', '-W7', '-I30', user])
