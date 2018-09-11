#!/bin/bash

cd /home/user/evr-indicators
find . -name indicators.xls -exec ./mysql_import.sh {} \;

./mysql_import_post_process.sh

./mysql_report.sh

