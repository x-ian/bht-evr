#!/bin/bash

MYSQL_TABLE="evr_indicators_v8"
MYSQL_USER="evr"
MYSQL_PW="evr"
MYSQL_DB="evr_monitoring"

# post import cleanup
mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB <<EOF
delete from $MYSQL_TABLE where CSV_version in ('1', '2', '3', '4');

update $MYSQL_TABLE set server_time = null where server_time = '';

update $MYSQL_TABLE set mt_start_count = '0' where mt_start_count in ('no such item', '');
update $MYSQL_TABLE set mt_start_count = '0' where mt_start_count is NULL;

-- update evr_indicators_v8 set http_speed = -1 
-- where http_speed in ('try:','http://192.168.21.254/jquery-1.11.1.min.js');

-- IGNORE necessary as some J2 realtime clocks often/always jump back to the same initial date
update IGNORE $MYSQL_TABLE inner join evr_sites on (evr_sites.name=$MYSQL_TABLE.name)
set $MYSQL_TABLE.name = evr_sites.uniq_name;
update IGNORE $MYSQL_TABLE inner join evr_sites on (evr_sites.name_2=$MYSQL_TABLE.name)
set $MYSQL_TABLE.name = evr_sites.uniq_name;
update IGNORE $MYSQL_TABLE inner join evr_sites on (evr_sites.name_3=$MYSQL_TABLE.name)
set $MYSQL_TABLE.name = evr_sites.uniq_name;
update IGNORE $MYSQL_TABLE inner join evr_sites on (evr_sites.name_4=$MYSQL_TABLE.name)
set $MYSQL_TABLE.name = evr_sites.uniq_name;
EOF

# update times if both server_time and local J2 realtime clock advance in the same way (less than 300 mins difference)

mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB >out <<EOF
update $MYSQL_TABLE set timestamp_corrected = str_to_date(server_time, '%Y%m%d-%H%i') where  server_time is not null;
EOF

# update timestamp_correct if the lowest and highest delta between local J2 time and server_time is not more than 10 minutes
# if above, then most likley something with the local J2 system time is wrong and unless there is a valid server_time record, we don't know at what time this was recorded
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
where (up - down) < 600) e5
where e4.name = e5.name
and e4.timestamp is not null and e4.server_time is not null
group by e4.name;
EOF
cat out | tr -d '\t' > out2
# remove first header row from mysql output
tail -n +2 out2 > out3

mysql -u $MYSQL_USER -p$MYSQL_PW $MYSQL_DB < out3

