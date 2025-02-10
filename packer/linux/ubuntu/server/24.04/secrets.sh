#!/bin/bash

# Install 1Password CLI if not installed:
# https://developer.1password.com/docs/cli/get-started/
# Example (for Linux):
# curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo tee /etc/apt/trusted.gpg.d/1password.asc
# echo 'deb [signed-by=/etc/apt/trusted.gpg.d/1password.asc] https://downloads.1password.com/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/1password.list
# sudo apt update && sudo apt install -y 1password-cli

# Create your secrets in 1Password:
# - Create an item in a vault (e.g., Secure Note or API Credential)
# - Set the appropriate field names
# - Reference them below using `op://vault/item/field`

# To run the script, use "source credentials.sh"
# To run this with Packer, use "source ../credentials.sh && packer build ubuntu-server-jammy.pkr.hcl"

# Unlock 1Password Vault
opunlock() {
    echo "OP_SESSION is not set..."
    echo "Signing in to 1Password..."
    export OP_SESSION=$(op signin --raw)
}

# Get and set variables
getsecrets() {
    echo "Setting Packer variables..."
    
    # Ensure session is active
    if ! op account list > /dev/null 2>&1; then
        opunlock
    fi

    # Fetch secrets from 1Password
    export PROXMOX_API_TOKEN_ID=$(op read "op://packer/proxmox/username")
    export PROXMOX_API_TOKEN_SECRET=$(op read "op://packer/proxmox/api")
    export PROXMOX_HOST=$(op read "op://packer/proxmox/host")
    export PROXMOX_PORT=$(op read "op://packer/proxmox/port")
    export PROXMOX_NODE=$(op read "op://packer/proxmox/node")
    export BUILD_USERNAME=$(op read "op://packer/build/username")
    export BUILD_PASSWORD=$(op read "op://packer/build/password")
    export BUILD_PASSWORD_ENCRYPTED=$(op read "op://packer/build/password-encrypted")
    export BUILD_SSH_PUB_KEY=$(op read "op://packer/build-ssh/public_key")
    export ANSIBLE_USERNAME=$(op read "op://packer/build/username")
    export ANSIBLE_PASSWORD=$(op read "op://packer/build/password")
    export ANSIBLE_PASSWORD_ENCRYPTED=$(op read "op://packer/build/password-encrypted")
    export ANSIBLE_SSH_PUB_KEY=$(op read "op://packer/ansible-ssh/public_key")
}

# Check if script is sourced
if [ "$0" = "$BASH_SOURCE" ]; then
    echo "Error: Script must be sourced"
    exit 1
fi

# Run functions
if [[ -n "$OP_SESSION" ]]
then
    getsecrets
else
    opunlock
    getsecrets
fi
