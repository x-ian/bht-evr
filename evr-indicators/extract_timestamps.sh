#!/bin/bash

# find . -name indicators.xls -exec extract_timestamps.sh {} \;

FILE=$1

DELTA_FILE=deltas_for_time_differences.csv
touch $DELTA_FILE

SERVER_TIME=$(date +%Y%m%d-%H%M)

LASTLINE=$(tail -1 $FILE)
SITE_NAME=$(echo $LASTLINE | awk -F',' '{print $3}')
LAST_SITE_TIMESTAMP=$(echo $LASTLINE | awk -F',' '{print $4}')

grep $SITE_NAME $DELTA_FILE
if [ $? -eq 1 ]; then
	# first time for this site to report
	echo "$SITE_NAME,$LAST_SITE_TIMESTAMP,$SERVER_TIME,first_time" >> $DELTA_FILE
else
	grep "$SITE_NAME,$LAST_SITE_TIMESTAMP" $DELTA_FILE
	if [ $? -eq 1 ]; then
		# this timestamp not yet reported; remove old entry and place in new one
		grep -v  "$SITE_NAME" $DELTA_FILE > $DELTA_FILE.2
		mv $DELTA_FILE.2 $DELTA_FILE
		# add new time stamp
		echo "$SITE_NAME,$LAST_SITE_TIMESTAMP,$SERVER_TIME" >> $DELTA_FILE
	fi
fi

