#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPTPATH

# SSH stuff
mkdir ~/.ssh
cp ssh-keys-from-evr-server/* ~/.ssh
# adjust permissions
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
# use EVR server host key
echo "# 192.168.21.254 SSH-2.0-OpenSSH_6.6.1p1 Ubuntu-2ubuntu2
192.168.21.254 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDDnFo/Wnyw8Eas8fdE2IsuXoJA/lO+ROHjV2fBPTqc9XDLCeATrbbJRpV/WgpW1RThGAmSH+km5/Bi28JinD+k=" >> ~/.ssh/known_hosts

# install cronjobs (careful: only run once!)
(crontab -l ; echo "0 * * * * /bin/bash ~/evr-indicators/evr-indicators.sh") | crontab -
(crontab -l ; echo "30 * * * * /bin/bash ~/evr-indicators/update-scripts-from-server.sh") | crontab -
(crontab -l ; echo "@reboot ~/evr-indicators/evr-bootcount.sh") | crontab -

# install cronjob for root
(sudo crontab -u root -l ; echo "@reboot /bin/bash /home/user/evr-indicators/get-serial.sh") | sudo crontab -u root -

echo .
echo .
echo "DON'T FORGET TO ADD USER user TO MIKROTIK WITHOUT password!!!"
echo .
echo .
