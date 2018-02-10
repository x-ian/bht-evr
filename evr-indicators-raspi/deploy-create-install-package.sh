#!/bin/bash

rm -rf ./evr-indicators-package
mkdir ./evr-indicators-package
cp evr-bootcount.sh evr-indicators.sh install.sh ../evr-indicators/maintenance.sh ../evr-indicators/update-scripts-from-server.sh ./evr-indicators-package
cp -R ../evr-indicators/ssh-keys-from-evr-server ./evr-indicators-package
tar czf evr-indicators-package.tgz evr-indicators-package

echo
echo "Copy dir ./evr-indicators-package to flash drive (ideally with an ext? partition), take it to an EVR touchscreen and invoke ./evr-indicators-package/install.sh from a shell"
echo
