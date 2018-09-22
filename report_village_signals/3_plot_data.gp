#!/usr/local/bin/gnuplot --persist

# call with gnuplot -c ./3_plot_data.gp Biwi ./tmp/Biwi

reset
set terminal png size 1200, 400

# Data file uses semikolon as a separator
set datafile separator ';'
 
# Title of the plot
set title "$0"
 
# We want a grid
set grid
 
# Ignore missing values
set datafile missing "NaN"
 
# X-axis label
set xdata time
set timefmt "%Y-%m-%d\ %H:%M"
 
# Title for Y-axis
set ylabel "Signal strength"
   
# generate a legend which is placed underneath the plot
set key outside top right box
 
# output into png file
set terminal png large
set output "$2"
  
# read data from file and generate plot
# warning are ok
plot "$1" using 1:2 with lines title columnhead \
  , "" using 1:3 with lines title columnhead \
  , "" using 1:4 with lines title columnhead \
  , "" using 1:5 with lines title columnhead \
  , "" using 1:6 with lines title columnhead \
  , "" using 1:7 with lines title columnhead \
  , "" using 1:8 with lines title columnhead \
  , "" using 1:9 with lines title columnhead \
  , "" using 1:10 with lines title columnhead \
  , "" using 1:11 with lines title columnhead \
  , "" using 1:12 with lines title columnhead \
  , "" using 1:13 with lines title columnhead \
  , "" using 1:14 with lines title columnhead \
  , "" using 1:15 with lines title columnhead \

