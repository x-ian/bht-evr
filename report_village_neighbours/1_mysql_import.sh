#!/bin/bash

MYSQL_TABLE=evr_indicators_v8
MYSQL_USER="evr"
MYSQL_PW="evr"
MYSQL_DB="evr_monitoring"

EXPECTED_COMMAS=41

rm -rf /tmp/village_neighbours
mkdir /tmp/village_neighbours
ALL_SITES=/tmp/village_neighbours/all_sites
OUT_FILE=/tmp/village_neighbours/evr_links_raw
OUT_FILE3=/tmp/village_neighbours/evr_links_raw_3
OUT_FILE2=/tmp/village_neighbours/evr_links_raw_2

#IN_FILE=$1

echo > $OUT_FILE
echo > $OUT_FILE2

cd /home/user/evr-indicators

# through all together into one CSV file
find . -name neibor-signa2.4G -exec echo {} \; > $ALL_SITES
while read site
do
	echo $site
	SITE_NAME=`dirname $site | tr -d './' `
	cat $site | tr ' ' ',' | tr -d 'dBm...' | sed "s/^/$SITE_NAME,/" >> $OUT_FILE
done < $ALL_SITES

# remove all old stuff
grep -v "201802" $OUT_FILE > $OUT_FILE3
grep -v "201803" $OUT_FILE3 > $OUT_FILE
grep -v "201804" $OUT_FILE > $OUT_FILE3
grep -v "201805" $OUT_FILE3 > $OUT_FILE
grep -v "201806" $OUT_FILE > $OUT_FILE3
grep -v "201807" $OUT_FILE3 > $OUT_FILE

# prepare CSV file for MySQL import
while read line
do
	NUMBER_COMMAS=`echo $line | awk -F "," '{print NF-1}'`
	MISSING_COMMAS=$(($EXPECTED_COMMAS - $NUMBER_COMMAS))

	#APPEND=`printf ,%.0s \\{1..$MISSING_COMMAS\\}`
	#APPEND=`printf '% $MISSING_COMMAS s'|tr " " "="`
	APPEND=`seq -s, $MISSING_COMMAS |tr -d '[:digit:]'`
	echo $line$APPEND >> $OUT_FILE2
done < $OUT_FILE

exit 0

# import neighbours for one sitee
mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB -e "truncate evr_links_raw"
mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB -e "LOAD DATA INFILE '/tmp/village_neighbours/evr_links_raw_2' into table evr_links_raw fields terminated BY ','"

# convert (transpose) to evr_links for ease of analysis
mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB <<EOF
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour1, strength1, null from evr_links_raw where neighbour1 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour1, strength=strength1;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour2, strength2, null from evr_links_raw where neighbour2 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour2, strength=strength2;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour3, strength3, null from evr_links_raw where neighbour3 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour3, strength=strength3;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour4, strength4, null from evr_links_raw where neighbour4 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour4, strength=strength4;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour5, strength5, null from evr_links_raw where neighbour5 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour5, strength=strength5;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour6, strength6, null from evr_links_raw where neighbour6 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour6, strength=strength6;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour7, strength7, null from evr_links_raw where neighbour7 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour7, strength=strength7;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour8, strength8, null from evr_links_raw where neighbour8 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour8, strength=strength8;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour9, strength9, null from evr_links_raw where neighbour9 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour9, strength=strength9;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour10, strength10, null from evr_links_raw where neighbour10 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour10, strength=strength10;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour11, strength11, null from evr_links_raw where neighbour11 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour11, strength=strength11;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour12, strength12, null from evr_links_raw where neighbour12 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour12, strength=strength12;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour13, strength13, null from evr_links_raw where neighbour13 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour13, strength=strength13;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour14, strength14, null from evr_links_raw where neighbour14 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour14, strength=strength14;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour15, strength15, null from evr_links_raw where neighbour15 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour15, strength=strength15;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour16, strength16, null from evr_links_raw where neighbour16 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour16, strength=strength16;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour17, strength17, null from evr_links_raw where neighbour17 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour17, strength=strength17;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour18, strength18, null from evr_links_raw where neighbour18 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour18, strength=strength18;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour19, strength19, null from evr_links_raw where neighbour19 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour19, strength=strength19;
INSERT INTO evr_links (name, timestamp, frequency, neighbour, strength, timestamp_server) 
SELECT name, timestamp, 'mesh', neighbour20, strength20, null from evr_links_raw where neighbour20 is not null
ON DUPLICATE KEY UPDATE neighbour=neighbour20, strength=strength20;
EOF


exit 0

DROP TABLE IF EXISTS evr_links_raw;
CREATE TABLE evr_links_raw (
  name  varchar(64),
  timestamp varchar(64),
  neighbour1 varchar(64),
  strength1 varchar(64),
  neighbour2 varchar(64),
  strength2 varchar(64),
  neighbour3 varchar(64),
  strength3 varchar(64),
  neighbour4 varchar(64),
  strength4 varchar(64),
  neighbour5 varchar(64),
  strength5 varchar(64),
  neighbour6 varchar(64),
  strength6 varchar(64),
  neighbour7 varchar(64),
  strength7 varchar(64),
  neighbour8 varchar(64),
  strength8 varchar(64),
  neighbour9 varchar(64),
  strength9 varchar(64),
  neighbour10 varchar(64),
  strength10 varchar(64),
  neighbour11 varchar(64),
  strength11 varchar(64),
  neighbour12 varchar(64),
  strength12 varchar(64),
  neighbour13 varchar(64),
  strength13 varchar(64),
  neighbour14 varchar(64),
  strength14 varchar(64),
  neighbour15 varchar(64),
  strength15 varchar(64),
  neighbour16 varchar(64),
  strength16 varchar(64),
  neighbour17 varchar(64),
  strength17 varchar(64),
  neighbour18 varchar(64),
  strength18 varchar(64),
  neighbour19 varchar(64),
  strength19 varchar(64),
  neighbour20 varchar(64),
  strength20 varchar(64)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
ALTER TABLE evr_links_raw ADD INDEX (name);
ALTER TABLE evr_links_raw ADD INDEX (name,timestamp);
