#!/bin/bash

/usr/bin/scp user@192.168.21.254:~/evr-indicators/evr-indicators.sh ~/evr-indicators/
/usr/bin/scp user@192.168.21.254:~/evr-indicators/evr-bootcount.sh ~/evr-indicators/
/usr/bin/scp user@192.168.21.254:~/evr-indicators/maintenance.sh ~/evr-indicators/

# invoke maintenance script
~/evr-indicators/maintenance.sh

# bad practise, but update this script as well
/usr/bin/scp user@192.168.21.254:~/evr-indicators/update-scripts-from-server.sh ~/evr-indicators/
