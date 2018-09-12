#!/bin/bash

MYSQL_TABLE=evr_indicators_v8
MYSQL_USER="evr"
MYSQL_PW="evr"
MYSQL_DB="evr_monitoring"

rm -rf /tmp/village_volts
mkdir /tmp/village_volts
chmod a+w /tmp/village_volts

ALL_SITES=`mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB --skip-column-names -e "select distinct(upper(name)) from $MYSQL_TABLE" -B`

while read -r line; do
	mysql -u root -proot $MYSQL_DB --skip-column-names <<EOF
	select name, timestamp_corrected, mt_voltage 
	from $MYSQL_TABLE 
	where timestamp_corrected >= (NOW() - INTERVAL 4 WEEK) and UPPER(name) in ('$line')
	order by name, timestamp_corrected
	into outfile '/tmp/village_volts/$line.csv' fields terminated by ';' lines terminated by '\n';
EOF
done <<< "$ALL_SITES"

