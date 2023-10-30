#!/bin/bash

read -p "Please enter your username: " username

wget -O "/home/$username/installed_packages.txt" "https://drive.google.com/uc?export=download&id=1gOv2LJIoAvF3HlQDRn9WquLwTCLkYLXl"

installed_packages="$(apt list --installed | awk -F/ '{print $1}' | tr '\n' ',')"

baseline_packages="$(cat "/home/$username/installed_packages.txt")"
extra_packages=$(comm -13 <(tr ',' '\n' <<< "$baseline_packages" | sort) <(tr ',' '\n' <<< "$installed_packages" | sort) | tr '\n' ',')

echo "$extra_packages" > "/home/$username/extra_packages.txt"

echo "Extra packages have been saved to /home/$username/extra_packages.txt"
