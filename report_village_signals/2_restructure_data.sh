#!/bin/bash

#set -euo pipefail

DISTINCT_SITES=`awk -F "\"*;\"*" '{print $2}' /home/user/bht-evr/report_village_signals/village_signals.csv | sort | uniq`

rm -f /home/user/bht-evr/report_village_signals/tmp/*

while read site
do
#	site=CHIKAMBA
	echo "Processing $site"
	if [ -z "$site" ]; then
		continue
	fi
	TMP_FILE=/home/user/bht-evr/report_village_signals/tmp/village_signals_$site

	rm -f $TMP_FILE
	rm -f /home/user/bht-evr/report_village_signals/data/$site

	egrep "^([^;]+;){1}$site;" /home/user/bht-evr/report_village_signals/village_signals.csv > $TMP_FILE

	DISTINCT_TIMESTAMPS=`egrep "^([^;]+;){1}$site;" $TMP_FILE | awk -F "\"*;\"*" '{print $1}' | sort | uniq`
	DISTINCT_NEIGHBOURS=`egrep "^([^;]+;){1}$site;" $TMP_FILE | awk -F "\"*;\"*" '{print $3}' | sort | uniq`

	# put header at top of file
	HEADER="TIMESTAMP"
	while read neighbour
	do
		if [ ! -z $neighbour ]; then
			HEADER="$HEADER;$neighbour"
		fi
	done <<< "$DISTINCT_NEIGHBOURS"
	echo $HEADER > /home/user/bht-evr/report_village_signals/data/$site
	
	while read timestamp
	do
		GNUPLOT_LINE=$timestamp
		while read neighbour
		do
			if [ -z "$neighbour" ]; then
				continue
			fi
			#echo $neighbour
			LINE=`egrep "^([^;]+;){1}$site;" $TMP_FILE | grep "$neighbour" | grep "$timestamp"`
			if [ $? -eq 0 ]; then
#			NEIGHBOUR=`echo $LINE | awk -F "\"*;\"*" '{print $3}'`
				STRENGTH=`echo $LINE | awk -F "\"*;\"*" '{print $4}'`
			else 
				STRENGTH=""
			fi
			GNUPLOT_LINE="$GNUPLOT_LINE;$STRENGTH"
		done <<< "$DISTINCT_NEIGHBOURS"
	
		echo $GNUPLOT_LINE >> /home/user/bht-evr/report_village_signals/data/$site
	done <<< "$DISTINCT_TIMESTAMPS"
	
done <<< "$DISTINCT_SITES"

