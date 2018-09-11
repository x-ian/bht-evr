#!/bin/bash

rm /tmp/village_signals.csv 

# traffic each minute for last 60 minutes
mysql -u root -pxian evr --skip-column-names <<EOF
select str_to_date(timestamp, '%Y%m%d-%H%i'), name, neighbour, replace(strength, 'dBm...', '') from evr_links 
into outfile '/tmp/village_signals.csv' fields terminated by ';' lines terminated by '\n';
EOF

cp /tmp/village_signals.csv .