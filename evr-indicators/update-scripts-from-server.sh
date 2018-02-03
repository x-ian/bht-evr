#!/bin/bash

/usr/bin/rsync -arv --append user@192.168.21.254:~/evr-indicators/evr-indicators.sh /home/user/evr-indicators/
/usr/bin/rsync -arv --append user@192.168.21.254:~/evr-indicators/evr-bootcount.sh /home/user/evr-indicators/
/usr/bin/rsync -arv --append user@192.168.21.254:~/evr-indicators/maintenance.sh /home/user/evr-indicators/

# invoke maintenance script
/home/user/evr-indicators/maintenance.sh

# bad practise, but update this script as well
/usr/bin/rsync -arv --append user@192.168.21.254:~/evr-indicators/update-scripts-from-server.sh /home/user/evr-indicators/

