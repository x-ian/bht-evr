#!/usr/local/bin/gnuplot --persist

# call with gnuplot -c ./3_plot_data.gp Biwi ./tmp/Biwi

reset
set terminal png size 2000, 400

# Data file uses semikolon as a separator
set datafile separator ';'
 
# Title of the plot
set title "$0"
 
# We want a grid
set grid
 
# Ignore missing values
#set datafile missing "NaN"
 
# X-axis label
set xdata time
set timefmt "%Y-%m-%d\ %H:%M"
 
# Title for Y-axis
set ylabel "Volts"
   
# generate a legend which is placed underneath the plot
set key outside top right box
 
# output into png file
set terminal png large
set output "$2"
  
  
plot "$1" u 2:3 w l  

#plot "$1" index 0 using 2:3 with lines, '' index 1 using 2:3 with lines

#plot for [IDX=0:43] "$1" IDX u 2:3 w lines title columnheader(1)

