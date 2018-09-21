#!/bin/bash

DISTINCT_SITES=`awk -F "\"*;\"*" '{print $2}' village_signals.csv | sort | uniq`

while read site
do
#	site=MGWADULA
	echo $site
	TMP_FILE=./tmp/village_signals_$site

	rm -f $TMP_FILE
	rm -f ./data/$site

	egrep "^([^;]+;){1}$site;" village_signals.csv > $TMP_FILE

	DISTINCT_TIMESTAMPS=`egrep "^([^;]+;){1}$site;" $TMP_FILE | awk -F "\"*;\"*" '{print $1}' | sort | uniq`
	DISTINCT_NEIGHBOURS=`egrep "^([^;]+;){1}$site;" $TMP_FILE | awk -F "\"*;\"*" '{print $3}' | sort | uniq`

	# put header at top of file
	HEADER="TIMESTAMP"
	while read neighbour
	do
		HEADER="$HEADER;$neighbour"
	done <<< "$DISTINCT_NEIGHBOURS"
	echo $HEADER > ./data/$site
	
	while read timestamp
	do
		GNUPLOT_LINE=$timestamp
		while read neighbour
		do
			LINE=`egrep "^([^;]+;){1}$site;" $TMP_FILE | grep $neighbour | grep "$timestamp"`
			NEIGHBOUR=`echo $LINE | awk -F "\"*;\"*" '{print $3}'`
			STRENGTH=`echo $LINE | awk -F "\"*;\"*" '{print $4}'`
			GNUPLOT_LINE="$GNUPLOT_LINE;$STRENGTH"
		done <<< "$DISTINCT_NEIGHBOURS"
	
		echo $GNUPLOT_LINE >> ./data/$site
	done <<< "$DISTINCT_TIMESTAMPS"
	
done <<< "$DISTINCT_SITES"

