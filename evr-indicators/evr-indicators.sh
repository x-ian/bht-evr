#!/bin/bash

# collect key infrastructure indicators for EVR (like connectivity and system uptime)

# wait for random up to 60 seconds to prevent all systems hitting the network at the same time
sleep $[ ( $RANDOM % 120 )  + 1 ]s

CSV_VERSION=2

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
#HOST=192.168.22.22
HOST=192.168.100.1
USER=user
set timeout 10
# for mikrotik bypass check of host key as this will change as J2s are moved around
LOGIN="ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $USER@$HOST"
IP=`$LOGIN "ip addr pr" | grep TA-MTEMA | awk '{print $2}' | sed -r 's/.{3}$//'`
NAME=`$LOGIN "sys ident print" | awk '{print $2}' | tr -d '\r\n'`
TIMESTAMP=$(date +%Y%m%d-%H%M)
MACS=$(cat /sys/class/net/*/address | tr "\n" " ")
#SERIAL_NUMBER=`sudo dmidecode -t system  | grep Serial | awk '{print $3}'`
SERIAL_NUMBER=`cat /home/user/evr-indicators/serial`
DMI_MODEL_VERBOSE=`dmesg | grep DMI | head -1 | tr  ',' ' '`
DMI_MODEL="${DMI_MODEL_VERBOSE:38:80}"
ROUTER_SERIAL=`$LOGIN "sys rout pri" | grep serial| awk '{print $2}' | tr -d '\r\n'`
ROUTER_MODEL=`$LOGIN "sys rout pri" | grep model| awk '{print $2}' | tr -d '\r\n'`
PARTITION_SIZE=`df -H /dev/sda1 | tail -1 |awk '{print $2}'`
DISK_MODEL_VERBOSE=`udisksctl status | grep sda`
DISK_MODEL="${DISK_MODEL_VERBOSE:0:25}"
LINUX_VERSION=`/usr/bin/lsb_release -d -s`

########## connectivity ##########

# mesh number of neigbhors
MESH_NEIGHBOR_COUNT=`$LOGIN "int wir reg pri" | grep -c Main` 

#MESH_NB_SIGNAL_5G=`$LOGIN "int wir reg pri" | grep Main| awk '{print $3 "\t"  $6}' | sed -r 's/.{9}$//'`
MESH_NB_SIGNAL_5G=`$LOGIN "int wir reg pri" | grep Main| awk '{print $3 "\t"  $6}'`
MESH_NB_SIGNAL_2G=`$LOGIN "int wir reg pri" | grep 2.4G| awk '{print $3 "\t"  $6}'`
#SCAN_CLUSTERS=`$LOGIN  "interface wireless scan Main duration=2" | grep   evr | awk '{print $4, $8, $11}'`

########## ping ##########

# ping
PING_TMP=$(mktemp /tmp/evr-ping.XXXXXX)
#ping -c 1 google.de > $PING_TMP
#ping -c 1 localhost > $PING_TMP
ping 192.168.21.254 -s 1024 -c 10 > $PING_TMP

# ping exit code
PING_EXIT_CODE=$?

# ping duplicates
grep "DUP" $PING_TMP
if [ $? -eq 1 ]; then
	PING_DUPS=NO_DUPLICATES
else
	PING_DUPS=DUPLICATES
fi

# ping packet loss
grep "error" $PING_TMP
if [ $? -eq 1 ]; then
	PING_PACKET_LOSS=$(grep "packet loss" $PING_TMP | awk -F "," '{print $3}' | awk '{print $1}' | tr -d '%')
else
	# ping output contains +error column in result, ping packet loss shifts from column 3 to 4
	PING_PACKET_LOSS=$(grep "packet loss" $PING_TMP | awk -F "," '{print $4}' | awk '{print $1}' | tr -d '%')
fi

# ping avg rrt
# choose line depending on your distribution
#PING_RRT_AVG=$(grep "round-trip" $PING_TMP | awk '{print $4}' | awk -F "/" '{print $2}')
PING_RRT_AVG=$(grep "rtt" $PING_TMP | awk '{print $4}' | awk -F "/" '{print $2}')

rm $PING_TMP

########## HTTP throughput ##########

# download a javascript library also required by news app, ~100 KB
URL_DOWNLOAD=http://192.168.21.254:3000/lib/jquery-1.11.1.min.js

HTTP=$(wget -O /dev/null $URL_DOWNLOAD 2>&1 | tail -2 | awk  '{ print $3 " " $4 }' | sed 's/[()]//g')
HTTP_SPEED=$(echo $HTTP | awk '{ print $1 }' | tr ',' '.')
HTTP_UNIT=$(echo $HTTP | awk '{ print $2 }')
if [ "$HTTP_UNIT" == "MB/s" ]; then
	HTTP_SPEED=$(awk 'BEGIN {OFMT="%.2f";print ("'"$HTTP_SPEED"'" * 1000) }')
fi

########## startups ##########

# create count files if necessary
if [ ! -f $SCRIPTPATH/evr-bootcount.log ]; then
    echo "0" > $SCRIPTPATH/evr-bootcount.log
fi
if [ ! -f $SCRIPTPATH/evr-crashcount.log ]; then
    echo "0" > $SCRIPTPATH/evr-crashcount.log
fi

STARTUP_COUNT=$(cat $SCRIPTPATH/evr-bootcount.log)
CRASH_COUNT=$(cat $SCRIPTPATH/evr-crashcount.log)

######### finalizing ##########

##Create directory with name of the village if the directory does not exist

mkdir -p $NAME

# print header & values to screen and to files
echo '$CSV_VERSION,$IP,$NAME,$TIMESTAMP,$MACS,$SERIAL_NUMBER,$ROUTER_SERIAL,$ROUTER_MODEL,$PING_EXIT_CODE,$PING_DUPS,$PING_PACKET_LOSS,$PING_RRT_AVG,$HTTP_SPEED,$MESH_NEIGHBOR_COUNT,$STARTUP_COUNT,$CRASH_COUNT,$DMI_MODEL,$DISK_MODEL,$PARTITION_SIZE,$LINUX_VERSION'
echo $CSV_VERSION,$IP,$NAME,$TIMESTAMP,$MACS,$SERIAL_NUMBER,$ROUTER_SERIAL,$ROUTER_MODEL,$PING_EXIT_CODE,$PING_DUPS,$PING_PACKET_LOSS,$PING_RRT_AVG,$HTTP_SPEED,$MESH_NEIGHBOR_COUNT,$STARTUP_COUNT,$CRASH_COUNT,$DMI_MODEL,$DISK_MODEL,$PARTITION_SIZE,$LINUX_VERSION
echo '$CSV_VERSION,$IP,$NAME,$TIMESTAMP,$MACS,$SERIAL_NUMBER,$ROUTER_SERIAL,$ROUTER_MODEL,$PING_EXIT_CODE,$PING_DUPS,$PING_PACKET_LOSS,$PING_RRT_AVG,$HTTP_SPEED,$MESH_NEIGHBOR_COUNT,$STARTUP_COUNT,$CRASH_COUNT,$DMI_MODEL,$DISK_MODEL,$PARTITION_SIZE,$LINUX_VERSION' > /home/user/evr-indicators/$NAME/indicators-header.txt 
echo $CSV_VERSION,$IP,$NAME,$TIMESTAMP,$MACS,$SERIAL_NUMBER,$ROUTER_SERIAL,$ROUTER_MODEL,$PING_EXIT_CODE,$PING_DUPS,$PING_PACKET_LOSS,$PING_RRT_AVG,$HTTP_SPEED,$MESH_NEIGHBOR_COUNT,$STARTUP_COUNT,$CRASH_COUNT,$DMI_MODEL,$DISK_MODEL,$PARTITION_SIZE,$LINUX_VERSION  >> /home/user/evr-indicators/$NAME/indicators.xls

## Tracking serial number of hardware per site
echo $NAME,$TIMESTAMP, $SERIAL_NUMBER >> /home/user/evr-indicators/$NAME/serial-number.xls
echo $TIMESTAMP,$ROUTER_SERIAL,$ROUTER_MODEL > /home/user/evr-indicators/$NAME/Router_details.xls
echo $TIMESTAMP  $MESH_NB_SIGNAL_2G >> /home/user/evr-indicators/$NAME/neibor-signa2.4G
echo $TIMESTAMP  $MESH_NB_SIGNAL_5G >> /home/user/evr-indicators/$NAME/neibor-signa5.0G
#echo $TIMESTAMP $SCAN_CLUSTERS >> /home/user/evr-indicators/$NAME/scan-clusters

# wait for 5 seconds to allow the data collection process to finalize before syncing the data with EVR server
sleep 5

/usr/bin/rsync -arv --append /home/user/evr-indicators/$NAME user@192.168.21.254:~/evr-indicators
