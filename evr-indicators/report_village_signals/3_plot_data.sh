#!/bin/bash

#export LC_CTYPE="en_US.UTF-8"

while read file
do
	echo $file
	gnuplot -c ./3_plot_data.gp $file ./data/$file ./graphs/$file.png
done <<< "`ls -1 data`"