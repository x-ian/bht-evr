#!/bin/bash

#LOGIN_J2=user@192.168.85.194
LOGIN_J2=user@192.168.85.195

ssh $LOGIN_J2 <<EOF
mkdir evr-indicators
mkdir evr-indicators/ssh-keys-from-evr-server
EOF

scp install.sh evr-bootcount.sh evr-indicators.sh get-serial.sh maintenance.sh update-scripts-from-server.sh $LOGIN_J2:evr-indicators/
scp ssh-keys-from-evr-server/* $LOGIN_J2:evr-indicators/ssh-keys-from-evr-server

ssh $LOGIN_J2 <<EOF
cd evr-indicators
./install.sh
EOF
