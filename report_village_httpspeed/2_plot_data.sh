#!/bin/bash

ALL=`ls -1 /tmp/village_httpspeed`

while read -r line; do
    echo $line
    gnuplot <<EOF
call "/home/user/bht-evr/report_village_httpspeed/plot_data.gp" "($line)" "/tmp/village_httpspeed/$line" "/var/www/html/evr-village-httpspeed/$line.png"
EOF
done <<< "$ALL"

