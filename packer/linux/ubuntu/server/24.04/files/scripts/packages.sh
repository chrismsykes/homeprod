#!/bin/bash

# Updating APT
echo "===> Updating Apt"
apt-get update -qq

# Install Additional Packages
echo "===> Installing additional packages"
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq      \
            acl             \
            bash-completion \
            ca-certificates \
            curl            \
            git             \
            gnupg           \
            htop            \
            plocate         \
            openssl         \
            pwgen           \
            resolvconf      \
            swapspace       \
            zsh


# Updating MLocate database
echo "===> Updating MLocate database"
updatedb
