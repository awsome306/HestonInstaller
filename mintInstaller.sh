#!/usr/bin/bash


#Update Package Manager
apt update

# Install the essentials
apt install git git-doc curl nano htop
apt install ndcu # Basically WizTree for linux.

# Install common languages
apt install python3 # Python
#curl https://sh.rustup.rs -sSf | sh # Install Rust and Cargo
apt install octave octave-doc octave-info octave-htmldoc
apt install octave-dev octave-dbg
apt install octave-control octave-image octave-io octave-optim octave-signal octave-statistics

# Install the basics
apt install neofetch 
#apt install tldr # Better man pages; This is broken???
apt install cmake #If you plan on compiling anything
apt install kdeconnect #To connect your phone sms messages, etc.
apt install bat # A better version of cat. 
# TODO: Add batcat alias to bashrc
# TODO: Add an alias for ncdu

# TODO: Consider helix editer vs. neovim, etc. 
# TODO: How to add tldr pages (better than man pages)

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

# Extensions
code --install-extension zhuangtongfa.Material-theme
code --install-extension PKief.material-icon-theme
code --install-extension ms-python.python 
code --install-extension GitHub.copilot
code --install-extension MathWorks.language-matlab 
code --install-extension ms-vscode-remote.remote-ssh
code --install-extension ms-python.autopep8
code --install-extension ms-python.pylance
code --install-extension ms-python.isort


# TODO: Populate user settings file with desired defaults

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



# Install Starship and NerdFonts

# Install Starship
curl -sS https://starship.rs/install.sh | sh
# Add to bashrc
echo '# Enable Starsihp' >> ~/.bashrc
echo 'eval "$(starship init bash)"' >> ~/.bashrc
source ~/.bashrc

# TODO: create custom config starship.toml
starship preset catppuccin-powerline -o ~/.config/starship.toml

# Install Nerdfonts
/bin/bash ./installFonts.sh

#TODO: Set vscode font default:

# KDE Connect for Phone SMS connection:
# apt install kdeconnect
# apt install kpeople-vcard

# Install eza using Cargo, not apt
#apt install eza
#TODO Update bashrc to include ls ==> eza alias
