#!/bin/bash

# You need to install the lastest snapclient/server from the github repo

# Then make sure amixer is installed to controll the volume output. 
y | apt install alsa-utils
amixer set Master 70%

# Don't forget to make sure the snapclient file is set correctly:

"SNAPCLIENT_OPTS='--host dockerhost.home'" >> /etc/default/snapclient
