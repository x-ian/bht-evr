#!/bin/bash

cd /home/user
tar czf evr-indicators-backup/evr-indicators-$(date +%Y%m%d-%H%M).tgz evr-indicators

cd /home/user/evr-indicators
find . -name indicators.xls -exec ./extract_timestamps.sh {} \;
