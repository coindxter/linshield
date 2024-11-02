# Determine the OS number and version
OS_NAME=$(lsb_release -si)
OS_VERSION=$(lsb_release -sr)

# Update the package list
if [ "$OS_NAME" == "Ubuntu" ]; then
    if [ "$(sh cat "../support-files/apt_sources/$OS_VERSION")" != "" ]; then
        sudo cp /etc/apt/sources.list ../backups/sources.list.$(date +%Y-%m-%d)
        sudo cat "../support-files/apt_sources/$OS_VERSION" > /etc/apt/sources.list
    else
        echo "$OS_NAME is supported but $OS_VERSION is not supported"
    fi
else
    echo "OS $OS_NAME not supported"
fi

# list the files in the /etc/apt/sources.list.d directory if any exist ask the user if they want to remove then if so backup the files and remove them
if [ "$(ls /etc/apt/sources.list.d)" != "" ]; then
    echo "The following files exist in /etc/apt/sources.list.d"
    for file in /etc/apt/sources.list.d/*; do
        echo -n "Do you want to remove $file? (y/n) " && read REMOVE_FILE
        if [ "$REMOVE_FILE" == "y" ]; then
            sudo cp -r "$file" "../backups/sources.list.d.$(date +%Y-%m-%d)"
            sudo rm -r "$file"
        else
            echo "Skipping $file"
        fi
    done
fi

# Update the package list
sudo apt-get update

# Update APT
sudo apt-get install --only-upgrade apt

# install app armor
sudo apt-get install apparmor apparmor-utils apparmor-profiles -y
# install fail2ban
sudo apt-get install fail2ban -y
# install libpam-pwquality
sudo apt-get install libpam-pwquality -y
# unattended-upgrades
sudo apt-get install unattended-upgrades -y
