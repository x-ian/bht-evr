#!/bin/bash

MYSQL_TABLE=evr_indicators_v8
MYSQL_USER="evr"
MYSQL_PW="evr"
MYSQL_DB="evr_monitoring"

CSV_FILE=/tmp/village_signals_$(date +%Y%m%d-%H%M%s).csv

#rm -f rm /tmp/village_signals.csv
#rm -rf /tmp/village_signals
#mkdir /tmp/village_signals
#chmod a+w /tmp/village_signals

ALL_SITES=`mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB --skip-column-names -e "select distinct(upper(name)) from $MYSQL_TABLE" -B`

mysql -u root -proot $MYSQL_DB --skip-column-names <<EOF
select str_to_date(timestamp, '%Y%m%d-%H%i'), name, neighbour, ifnull(replace(strength, 'dBm...', ''),'') from evr_links 
into outfile '$CSV_FILE' fields terminated by ';' ESCAPED BY "" lines terminated by '\n' ;
EOF

cp $CSV_FILE /home/user/bht-evr/report_village_signals/village_signals.csv 
