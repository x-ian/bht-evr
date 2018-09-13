#!/bin/bash

# find . -name indicators.xls -exec mysql_import.sh {} \;

FILE=$1

FILE_WITHOUT_QUOTES=$1.without_quotes
sed 's/"//g' $FILE | sed 's/'"'"'//g' | sed 's/\`//g' > $FILE_WITHOUT_QUOTES

MYSQL_TABLE="evr_indicators_v8"
MYSQL_USER="root"
MYSQL_PW="root"
MYSQL_DB="evr_monitoring"

DELTA_FILE=last_imported_lines.csv
touch $DELTA_FILE

NEW_LAST_LINE=$(tail -1 $FILE_WITHOUT_QUOTES)
SITE_NAME=$(echo $NEW_LAST_LINE | awk -F',' '{print $3}')

if [ ! -z $SITE_NAME ]; then
	grep $SITE_NAME $DELTA_FILE >/dev/null
	if [ $? -eq 1 ]; then
		# first time for this site to import data
		echo "$SITE_NAME;$NEW_LAST_LINE" >> $DELTA_FILE
		# import all
		echo "Import all $FILE_WITHOUT_QUOTES"

		mysql -u $MYSQL_USER -p$MYSQL_PW  --local-infile=1 $MYSQL_DB -e "load data local infile '$FILE_WITHOUT_QUOTES' into table $MYSQL_TABLE fields terminated by ',';"
	
	else
		grep "$SITE_NAME;$NEW_LAST_LINE" $DELTA_FILE >/dev/null
		if [ $? -eq 1 ]; then
			# this line not yet imported; remove old entry and place in new one plus import all new lines
			OLD_LAST_LINE=$(grep "$SITE_NAME" $DELTA_FILE | awk -F';' '{print $2}')
			grep -A1000000 "$OLD_LAST_LINE" $FILE_WITHOUT_QUOTES | tail -n +2 > new_data.csv
			echo "Import new data from $FILE_WITHOUT_QUOTES"
			#mysql -u $MYSQL_USER -p$MYSQL_PW --local-infile=1 $MYSQL_DB -e "load data local infile '$1' into table $MYSQL_TABLE fields terminated by ',';"
			mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB  --local-infile=1 -e "load data local infile 'new_data.csv' into table $MYSQL_TABLE fields terminated by ',';"
			#rm -f new_data.csv
		
			grep -v  "$SITE_NAME" $DELTA_FILE > $DELTA_FILE.2
			mv $DELTA_FILE.2 $DELTA_FILE
			echo "$SITE_NAME;$NEW_LAST_LINE" >> $DELTA_FILE
		else
			echo "No new data found for $SITE_NAME; skipping"
			exit 0
		fi
	fi
else
	echo "Unable to process $FILE_WITHOUT_QUOTES"
	exit 0
fi

exit 0

# ALTER TABLE evr_indicators_v6b ADD COLUMN timestamp_corrected DATETIME NULL DEFAULT NULL AFTER server_time;
# ALTER TABLE evr_indicators_v6b ADD INDEX (timestamp_corrected);

# post import cleanup
mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB <<EOF
update $MYSQL_TABLE set server_time = null where server_time = '';

update $MYSQL_TABLE inner join evr_sites on (evr_sites.name=$MYSQL_TABLE.name)
set $MYSQL_TABLE.name = evr_sites.uniq_name;
update $MYSQL_TABLE inner join evr_sites on (evr_sites.name_2=$MYSQL_TABLE.name)
set $MYSQL_TABLE.name = evr_sites.uniq_name;
update $MYSQL_TABLE inner join evr_sites on (evr_sites.name_3=$MYSQL_TABLE.name)
set $MYSQL_TABLE.name = evr_sites.uniq_name;
update $MYSQL_TABLE inner join evr_sites on (evr_sites.name_4=$MYSQL_TABLE.name)
set $MYSQL_TABLE.name = evr_sites.uniq_name;
EOF

# update times if both server_time and local J2 realtime clock advance in the same way (less than 300 mins difference)

mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB >out <<EOF
update $MYSQL_TABLE set timestamp_corrected = str_to_date(server_time, '%Y%m%d-%H%i') where  server_time is not null;
EOF

mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB >out <<EOF
select 
"update $MYSQL_TABLE set timestamp_corrected=date_add(str_to_date(timestamp, '%Y%m%d-%H%i'), interval ", 
avg(timestampdiff(second, str_to_date(e4.timestamp, '%Y%m%d-%H%i'), str_to_date(e4.server_time, '%Y%m%d-%H%i'))) as delta,
" second) where server_time is null and name=\'",
e4.name,
"\';"
 from $MYSQL_TABLE e4, 
(select *, (up-down) from (
(select name, max(diff) as up, min(diff) as down from 
(select e.name, 
e.timestamp, 
e.server_time, 
timestampdiff(second, str_to_date(e.timestamp, '%Y%m%d-%H%i'), str_to_date(e.server_time, '%Y%m%d-%H%i')) as diff
from $MYSQL_TABLE e) 
e2 group by name) e3)
where (up - down) < 300) e5
where e4.name = e5.name
and e4.timestamp is not null and e4.server_time is not null
group by e4.name;
EOF
cat out | tr -d '\t' > out2

mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB < out2

