#!/bin/bash

MYSQL_TABLE=evr_indicators_v8
MYSQL_USER="evr"
MYSQL_PW="evr"
MYSQL_DB="evr_monitoring"

rm -rf /tmp/village_httpspeed
mkdir /tmp/village_httpspeed
chmod a+w /tmp/village_httpspeed

ALL_SITES=`mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB --skip-column-names -e "select distinct(upper(name)) from $MYSQL_TABLE" -B`

while read -r line; do
	mysql -u root -proot $MYSQL_DB --skip-column-names <<EOF
	select name, timestamp_corrected, 
	REPLACE(
		REPLACE(
			REPLACE(
				REPLACE(http_speed, ' KB/s', ''),
				'http://192.168.21.254/jquery-1.11.1.min.js 192.168.21.254:80...',
				'-20'
			),
			'http://192.168.21.254/jquery-1.11.1.min.js',
			'-20'
		),
		'try:',
		'-20'
	)
	from $MYSQL_TABLE 
	where timestamp_corrected >= (NOW() - INTERVAL 4 WEEK) and UPPER(name) in ('$line')
	order by name, timestamp_corrected
	into outfile '/tmp/village_httpspeed/$line.csv' fields terminated by ';' lines terminated by '\n';
EOF
done <<< "$ALL_SITES"
