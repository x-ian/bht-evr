#!/bin/bash

rm -rf ./evr-indicators
mkdir ./evr-indicators
cp evr-bootcount.sh evr-indicators.sh get-serial.sh install.sh maintenance.sh update-scripts-from-server.sh ./evr-indicators
cp -R ssh-keys-from-evr-server ./evr-indicators

echo
echo "Copy dir ./evr-indicators to flash drive (ideally with an ext? partition), take it to an EVR touchscreen and invoke ./evr-indicators/install.sh from a shell"
echo
