#!/usr/bin/bash

# Needs -y in front of ALL the apt installs 

#Update Package Manager
apt update

# Install the essentials
apt install curl nano htop git git-doc 
# git config credential.helper store # Enables storing passwords so you don't have to keep logging in
apt install ncdu # Basically WizTree for linux.

# Install common languages
apt install python3 # Python
# Installing Rust seems to be kinda weird. Like, it doesn't seem to want to work with sudo?
curl https://sh.rustup.rs -sSf | sh -s -- -yqV # Install Rust and Cargo, yes, quietly, output
apt install octave octave-doc octave-info octave-htmldoc
apt install octave-dev octave-dbg
apt install octave-control octave-image octave-io octave-optim octave-signal octave-statistics

# Install the basics
apt install btop 
apt install fastfetch   # neofetch is no more...
echo "alias neofetch='fastfetch'" >> .bash_aliases
apt install cmake build-essential #If you plan on compiling anything, including many rust/cargo pkgs
apt install kdeconnect  #To connect your phone sms messages, etc.
apt install bat         # A better version of cat. 
echo "alias cat='batcat'" >> ~/.bash_aliases
apt install ripgrep     # A better version of grep
apt install trash-cli   # Send to trash (instead of deleting)
apt install gh          # GitHub CLI tool

cargo install tlrc --locked --quiet     # tldr, a better version of the man pages
cargo install fd-find --quiet           # fd, A better version of find
cargo install eza --quiet               # Better version of ls
cargo install zoxide --locked --quiet   # Better version of cd
# Add to bashrc
echo '# Enable Zoxide' >> ~/.bashrc
echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
source ~/.bashrc

# TODO: Add an alias for ncdu
# TODO: Add alias for eza / ls 
# TODO Update bashrc to include ls ==> eza alias

# # OPTIONAL: RUST Replacements for core utils
# apt install rust-coreutils
# # To use it:
# export PATH=/usr/lib/cargo/bin/coreutils:$PATH

# Install Common Desktop Apps (via Flathub)
apt install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub com.bambulab.BambuStudio
echo "alias bambu='flatpak run com.bambulab.BambuStudio'" >> ~/.bash_aliases

flatpak install flathub md.obsidian.Obsidian
echo "alias obsidian='flatpak run md.obsidian.Obsidian'" >> ~/.bash_aliases

flatpak install flathub one.ablaze.floorp
flatpak install com.tomjwatson.Emote



# Install Starship
cargo install starship --locked --quiet
# Add to bashrc
echo '# Enable Starsihp' >> ~/.bashrc
echo 'eval "$(starship init bash)"' >> ~/.bashrc
source ~/.bashrc

# TODO: create custom config starship.toml
starship preset catppuccin-powerline -o ~/.config/starship.toml

# Install Nerdfonts
/bin/bash ./installFonts.sh


# TODO: Consider helix editor vs. neovim, etc. 


# Add git config:
git config --global user.name "Joey Heston"
git config --global user.email 71984403+awsome306@users.noreply.github.com
git config --global color.ui auto

# Install VSCode and extensions
apt install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg

apt install apt-transport-https
apt update 
apt install code

# VSCode Extensions
/bin/bash ./codeUpgrade.sh
# VSCode Settings
/bin/bash 


# TODO: Populate user settings file with desired defaults, including fonts

# echo
# ~/.config/Code/User/settings.json

# Install Python Packages
pip install scipy numpy pandas sympy matplotlib 
#pip install tensorflow
pip install requests beautifulsoup4

# Install Brave Browser 
curl -fsS https://dl.brave.com/install.sh | sh

# Install Signal and Element
# Add Signal to apt
# NOTE: These instructions only work for 64-bit Debian-based Linux distributions such as Ubuntu, Mint etc.
# 1. Install our official public software signing key:
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
# 2. Add our repository to your list of repositories:
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
    tee /etc/apt/sources.list.d/signal-xenial.list
# 3. Update your package database and install Signal:
apt update

# Add Element messenger to apt 
apt install -y wget apt-transport-https
wget -O /usr/share/keyrings/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main" | tee /etc/apt/sources.list.d/element-io.list
apt update

# Install Signal and Element
apt install element-desktop signal-desktop


# KVM
apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager


# Install Wireguard VPN and SMB tools 
apt install wireguard
apt install resolvconf #Needed on Mint to resolve DNS

#TODO: Grab a copy of the wireguard conf somehow (securely)

apt install cifs-utils smbclient
#mount -t cifs -o username=joeymint password=Bu2eL0dytE4xSn //192.168.2.1/bigsmb /mnt/bigsmb/

# Install Docker and configure

# #Uninstall conflicting
# for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc
# do 
#      apt-get remove $pkg
# done
# # Add Docker's official GPG key:
#  apt-get update
#  apt-get install ca-certificates curl
#  install -m 0755 -d /etc/apt/keyrings
#  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
#  chmod a+r /etc/apt/keyrings/docker.asc

# # Add the repository to Apt sources:
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
#    tee /etc/apt/sources.list.d/docker.list > /dev/null
#  apt update
# #Install
# apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# # Configuration
# groupadd docker
# usermod -aG docker $USER
# newgrp docker


# KDE Connect for Phone SMS connection:
# apt install kdeconnect
# apt install kpeople-vcard

