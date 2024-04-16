#!/bin/bash

#^ DONT COPY SHEBANG LINE!
# The "ESI" version:
# Install DEPENDENCIES 
sudo apt-get update
sudo apt-get install build-essential flex bison cmake zlib1g-dev libboost-system-dev libboost-thread-dev libopenmpi-dev openmpi-bin gnuplot libreadline-dev libncurses-dev libxt-dev
sudo apt-get install qt4-dev-tools libqt4-dev libqt4-opengl-dev freeglut3-dev libqtwebkit-dev
sudo apt-get install libscotch-dev libcgal-dev
# Add the repository
curl https://dl.openfoam.com/add-debian-repo.sh | sudo bash

# Update the repository information
sudo apt-get update

# Install preferred package. Eg,
sudo apt-get install openfoam2312-default

# Use the openfoam shell session. Eg,
# openfoam2312

# Install Paraview
sudo apt install paraview

# Install Helyx-OS OpenFOAM GUI (Linux Only, open source)






# Install fingerprint reader "drivers"
# https://wiki.debian.org/SecurityManagement/fingerprint%20authentication
apt install fprintd libpam-fprintd
