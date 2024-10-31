#!/usr/bin/env bash

# Install dependencies
apti vim neovim gawk sed

# Set aliases for vim and nvim
if [ -x /usr/bin/nvim ]; then
    alias vim="/usr/bin/nvim"
else
    alias nvim="/usr/bin/vim"
fi

# Display success message
psuccess "Installed core dependencies"