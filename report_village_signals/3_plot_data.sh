#!/bin/bash

#export LC_CTYPE="en_US.UTF-8"

while read file
do
	echo $file
    gnuplot <<EOF
call "/home/user/bht-evr/report_village_signals/3_plot_data.gp" "$file" "./data/$file" "/var/www/html/evr-village-signals/$file.png"
EOF

	#gnuplot -c ./3_plot_data.gp $file ./data/$file ./graphs/$file.png
done <<< "`ls -1 data`"
