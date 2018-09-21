#!/bin/bash

cd /home/user/evr-indicators
find . -name indicators.xls -exec /home/user/bht-evr/mysql/mysql_import.sh {} \;

/home/user/bht-evr/mysql/mysql_import_post_process.sh

/home/user/bht-evr/mysql/mysql_report.sh

