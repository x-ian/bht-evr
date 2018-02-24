#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Create directory & copy scripts
mkdir ~/evr-indicators
cd $SCRIPTPATH
cp evr-bootcount.sh evr-indicators.sh get-serial.sh maintenance.sh update-scripts-from-server.sh ~/evr-indicators
chmod +x ~/evr-indicators/*.sh

cd ~/evr-indicators
./install.sh
