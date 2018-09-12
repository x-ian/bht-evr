#!/bin/bash

ALL=`ls -1 /tmp/village_volts`

while read -r line; do
    echo $line
    gnuplot <<EOF
call "/home/user/evr-indicators/report_village_volts/plot_data.gp" "($line)" "/tmp/village_volts/$line" "/var/www/html/evr-village-volts/$line.png"
EOF
done <<< "$ALL"

