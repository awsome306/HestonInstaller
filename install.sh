#!/bin/bash

OS=$(lsb_release -si)
VER=$(lsb_release -sr)
CN=$(lsb_release -sc)
printf "This is: $OS \nVersion: $VER \nCodename: $CN\n"


# Update aliases:
aliases_list="
alias code=codium
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias sysupdate='sudo apt update; sudo apt upgrade -y; sudo apt autoremove -y; sudo apt autoclean -y'
"

if [ ! -f ~/.bash_aliases ] || ( ! grep -q 'alias code=codium' ~/.bash_aliases ); then
    printf "$aliases_list" > ~/.bash_aliases
    . ~/.bash_aliases
    . ~/.bashrc
    printf "Added new aliases to file.\n"
else
    printf "Aliases file already exists. Aliases not written.\n"
fi

# Download EDUROAM untility for Notre Dame
#wget https://cloud.securew2.com/public/18738/eduroam/?run

# >> appends
# > writes to 
# Sed is used to edit one line in a file that already exists:
#sed 's/# autologin=dgod/autologin=ubuntu/' /path/to/file
#sed -i 's/# autologin=dgod/autologin=ubuntu/' /path/to/file


## Update package manager
if [[ "$OS" = "Debian" ]] || [[ "$OS" = "Ubuntu" ]]; then
    apt update
fi

# Install git and neofetch, and curl
if [[ "$OS" = "Debian" ]] || [[ "$OS" = "Ubuntu" ]]; then
    y | apt install git git-doc
    y | apt install neofetch
    y | apt install curl vim nano htop
elif [[ "$OS" = "FreeBSD" ]]; then
    pkg install neofetch
    pkg install git
elif [[ "$OS" = "Fedora" ]]; then
    dnf install git
    dnf install neofetch
else
    fprintf "$OS is not supported"
fi

# Add git config:
git config --global user.name "Joey Heston"
git config --global user.email 71984403+awsome306@users.noreply.github.com
git config --global color.ui auto

## Install DOCKER:
# centos debian fedora raspbian rhel sles static ubuntu
if [[ "$OS" = "Debian" ]] || [[ "$OS" = "Ubuntu" ]]; then
    # Uninstall Docker
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt remove $pkg; done

    # Add Docker's official GPG key:
    y | apt install ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings


    if [[ "$OS" = "Ubuntu" ]]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        # Add the repository to Apt sources:
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
        # Change $VERSION_CODENAME to $UBUNTU_CODENAME
    fi

    if [[ "$OS" = "Debian" ]]; then
        curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        # Add the repository to Apt sources:
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi
    apt update
    apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

## Install VSCodium:
if [[ "$OS" = "Debian" ]] || [[ "$OS" = "Ubuntu" ]]; then
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
        | gpg --dearmor \
        | dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
        | tee /etc/apt/sources.list.d/vscodium.list
    apt update && apt install codium
elif [[ "$OS" = "Fedora" ]]; then
    printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h" | tee -a /etc/yum.repos.d/vscodium.repo
    rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
    dnf install codium
fi
# # Grant execution permissions to the script
# chmod +x install.sh
