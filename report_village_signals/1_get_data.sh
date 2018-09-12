#!/bin/bash

MYSQL_TABLE=evr_indicators_v8
MYSQL_USER="evr"
MYSQL_PW="evr"
MYSQL_DB="evr_monitoring"

rm -rf /tmp/village_signals
mkdir /tmp/village_signals
chmod a+w /tmp/village_signals

ALL_SITES=`mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB --skip-column-names -e "select distinct(upper(name)) from $MYSQL_TABLE" -B`


# traffic each minute for last 60 minutes
mysql -u root -pxian evr --skip-column-names <<EOF
select str_to_date(timestamp, '%Y%m%d-%H%i'), name, neighbour, replace(strength, 'dBm...', '') from evr_links 
into outfile '/tmp/village_signals.csv' fields terminated by ';' lines terminated by '\n';
EOF

cp /tmp/village_signals.csv .