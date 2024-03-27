#!/bin/bash

#^ DONT COPY SHEBANG LINE!
# The "ESI" version:
# Add the repository
curl https://dl.openfoam.com/add-debian-repo.sh | sudo bash

# Update the repository information
sudo apt-get update

# Install preferred package. Eg,
sudo apt-get install openfoam2312-default

# Use the openfoam shell session. Eg,
# openfoam2312



# Install fingerprint reader "drivers"
# https://wiki.debian.org/SecurityManagement/fingerprint%20authentication
apt install fprintd libpam-fprintd
