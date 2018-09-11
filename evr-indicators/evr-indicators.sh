#!/bin/bash

# collect key infrastructure indicators for EVR (like connectivity and system uptime)

# wait for random up to 60 seconds to prevent all systems hitting the network at the same time
sleep $[ ( $RANDOM % 120 )  + 1 ]s

# try to set system time based on EVR server
#requires root to change config
# run sudo visudo and add this line: user ALL=(ALL) NOPASSWD: /bin/date
#SERVER_TIME=`ssh user@192.168.21.254 date`
#sudo date --set="$SERVER_TIME"
SERVER_TIME=`ssh -o PasswordAuthentication=no user@192.168.21.254 date +%Y%m%d-%H%M`

CSV_VERSION=9

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
#HOST=192.168.22.22
HOST=192.168.100.1
USER=user
set timeout 10
# for mikrotik bypass check of host key as this will change as J2s are moved around
LOGIN="ssh -oKexAlgorithms=diffie-hellman-group1-sha1,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1 -oCiphers=3des-cbc,blowfish-cbc,aes128-cbc,aes128-ctr,aes256-ctr -oStrictHostKeyChecking=no -oHostKeyAlgorithms=+ssh-dss -oUserKnownHostsFile=/dev/null $USER@$HOST"
IP=`$LOGIN "ip addr pr" | grep TA-MTEMA | awk '{print $2}' | sed -r 's/.{3}$//'`
IP2=`$LOGIN "ip addr pr" | grep MESH-BRIDGE | awk '{print $2}' | sed -r 's/.{3}$//'`
NAME=`$LOGIN "sys ident print" | tr -d '\r\n' | tr -d ' ' | sed 's/name://g'`
ROUTER_SERIAL=`$LOGIN "sys rout pri" | grep serial| awk '{print $2}' | tr -d '\r\n'`
#SERIAL_NUMBER=`sudo dmidecode -t system  | grep Serial | awk '{print $3}'`
SERIAL_NUMBER=`cat ~/evr-indicators/serial`
LOGFILE_PATH=`echo $NAME`_`echo $SERIAL_NUMBER`_`echo $ROUTER_SERIAL`
TIMESTAMP=$(date +%Y%m%d-%H%M)
MACS=$(cat /sys/class/net/*/address | tr "\n" " ")
DMI_MODEL_VERBOSE=`dmesg | grep DMI | head -1 | tr  ',' ' '`
DMI_MODEL="${DMI_MODEL_VERBOSE:38:80}"
ROUTER_MODEL=`$LOGIN "sys rout pri" | grep model| awk '{print $2}' | tr -d '\r\n'`
ROUTER_MAC=`$LOGIN "interface wireless print" | grep Main | awk '{print $4}'`
PARTITION_SIZE=`df -H | tail -1 |awk '{print $2}'`
DISK_MODEL_VERBOSE=`udisksctl status | grep sda`
DISK_MODEL="${DISK_MODEL_VERBOSE:0:25}"
LINUX_VERSION=`/usr/bin/lsb_release -d -s`
UPTIME=`/usr/bin/uptime | /usr/bin/awk '{print $3} {print $4}' | /bin/sed 's/,//g'`
MT_VOLTAGE=`$LOGIN "sys health print" | grep voltage | awk '{print $2}' | tr -d '\r\n' | tr -d 'V'`
MT_TEMP=`$LOGIN "sys health print" | grep temp | awk '{print $2}' | tr -d '\r\n' | tr -d 'C'`
MT_UPTIME=`$LOGIN "sys resource print" | grep uptime | awk '{print $2}' | tr -d '\r\n'`
MT_CPU_LOAD=`$LOGIN "sys resource print" | grep cpu-load | awk '{print $2}' | tr -d '\r\n' | tr -d '%'`
MT_STARTUP_COUNT=`$LOGIN ":put [/file get evrStartupCounter.txt contents];" | tr -d '\r\n'`
########## connectivity ##########

MESH_CLUSTER=`$LOGIN "interface wireless print" | grep " ssid=" | tr -d '\r\n' | sed 's/^.*ssid=//g'`
# mesh number of neigbhors
MESH_NEIGHBOR_COUNT=`$LOGIN "int wir reg pri" | grep -c -E "MESH-INTERFACE|wlan1"` 
#MESH_NEIGHBOR_COUNT_2G=`$LOGIN "int wir reg pri" | grep -c 2.4G` 

#MESH_NB_SIGNAL_5G=`$LOGIN "int wir reg pri" | grep Main| awk '{print $3 "\t"  $6}' | sed -r 's/.{9}$//'`
MESH_NB_SIGNAL_2G=`$LOGIN "int wir reg pri" | grep -E "MESH-INTERFACE|wlan1" | awk '{print $3 "\t"  $6}'`
#MESH_NB_SIGNAL_2G=`$LOGIN "int wir reg pri" | grep 2.4G| awk '{print $3 "\t"  $6}'`
#SCAN_CLUSTERS=`$LOGIN  "interface wireless scan Main duration=2" | grep   evr | awk '{print $4, $8, $11}'`

########## RSTP ##########
# MAC of Tonde bridge: 6C:3B:6B:94:A4:41

# MAC address of mesh node
MAC=`$LOGIN "/int bri pri" | grep -A 3 MESH-BRIDGE | grep 'mac-address=' | awk '{print $2}' | sed -r 's/mac-address=//g' | tr -d '\r\n'`

# root port of mesh node
# assuming MESH-BRIDGE interface is always on number 1
ROOT_PORT=`$LOGIN "/int bri mon 1 once" | grep root-port | awk '{print $2}' | tr -d '\r\n'`
ROOT_PORT_NUMBER=`$LOGIN "/int bri por pri" | grep $ROOT_PORT | awk '{print $1}' | tr -d '\r\n'`

# RSTP details
ROOT_PORT_DETAILS=`$LOGIN "/int bri por mon $ROOT_PORT_NUMBER once" | grep -A 2 root-path-cost`
ROOT_PATH_COST=`echo "$ROOT_PORT_DETAILS" | grep root-path-cost | awk '{print $2}' | tr -d '\r\n'`
DESIGNATED_BRIDGE=`echo "$ROOT_PORT_DETAILS" | grep designated-bridge | awk '{print $2}'| sed 's/0x[0-9]*.//g' | tr -d '\r\n'`
DESIGNATED_COST=`echo "$ROOT_PORT_DETAILS" | grep designated-cost | awk '{print $2}' | tr -d '\r\n'`
DESIGNATED_BRIDGE_SIGNAL=`$LOGIN "int wir reg pri" | grep $DESIGNATED_BRIDGE | awk '{print $6}'`

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
URL_DOWNLOAD=http://192.168.21.254/jquery-1.11.1.min.js

HTTP=$(wget --tries=2 --timeout=10 -O /dev/null $URL_DOWNLOAD 2>&1 | tail -2 | awk  '{ print $3 " " $4 }' | sed 's/[()]//g')
HTTP_SPEED=$HTTP
#HTTP_SPEED=$(echo $HTTP | awk '{ print $1 }' | tr ',' '.')
#HTTP_UNIT=$(echo $HTTP | awk '{ print $2 }')
#if [ "$HTTP_UNIT" == "MB/s" ]; then
#	HTTP_SPEED=$(awk 'BEGIN {OFMT="%.2f";print ("'"$HTTP_SPEED"'" * 1000) }')
#fi

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

mkdir -p ~/evr-indicators/$LOGFILE_PATH

# print header & values to screen and to files
echo '$CSV_VERSION,$IP,$NAME,$TIMESTAMP,$MACS,$SERIAL_NUMBER,$ROUTER_SERIAL,$ROUTER_MODEL,$PING_EXIT_CODE,$PING_DUPS,$PING_PACKET_LOSS,$PING_RRT_AVG,$HTTP_SPEED,$MESH_NEIGHBOR_COUNT,$STARTUP_COUNT,$CRASH_COUNT,$DMI_MODEL,$DISK_MODEL,$PARTITION_SIZE,$LINUX_VERSION,$UPTIME,$MT_VOLTAGE,$MT_TEMP,$MT_UPTIME,$MT_CPU_LOAD,$SERVER_TIME,$ROUTER_MAC,$MESH_NEIGHBOR_COUNT_2G,$MESH_CLUSTER,$MAC,$ROOT_PORT,$ROOT_PATH_COST,$DESIGNATED_BRIDGE,$DESIGNATED_COST,$IP2,$DESIGNATED_BRIDGE_SIGNAL,timestamp_corrected,$MT_STARTUP_COUNT'
echo $CSV_VERSION,$IP,$NAME,$TIMESTAMP,$MACS,$SERIAL_NUMBER,$ROUTER_SERIAL,$ROUTER_MODEL,$PING_EXIT_CODE,$PING_DUPS,$PING_PACKET_LOSS,$PING_RRT_AVG,$HTTP_SPEED,$MESH_NEIGHBOR_COUNT,$STARTUP_COUNT,$CRASH_COUNT,$DMI_MODEL,$DISK_MODEL,$PARTITION_SIZE,$LINUX_VERSION,$UPTIME,$MT_VOLTAGE,$MT_TEMP,$MT_UPTIME,$MT_CPU_LOAD,$SERVER_TIME,$ROUTER_MAC,$MESH_NEIGHBOR_COUNT_2G,$MESH_CLUSTER,$MAC,$ROOT_PORT,$ROOT_PATH_COST,$DESIGNATED_BRIDGE,$DESIGNATED_COST,$IP2,$DESIGNATED_BRIDGE_SIGNAL,timestamp_corrected,$MT_STARTUP_COUNT
echo '$CSV_VERSION,$IP,$NAME,$TIMESTAMP,$MACS,$SERIAL_NUMBER,$ROUTER_SERIAL,$ROUTER_MODEL,$PING_EXIT_CODE,$PING_DUPS,$PING_PACKET_LOSS,$PING_RRT_AVG,$HTTP_SPEED,$MESH_NEIGHBOR_COUNT,$STARTUP_COUNT,$CRASH_COUNT,$DMI_MODEL,$DISK_MODEL,$PARTITION_SIZE,$LINUX_VERSION,$UPTIME,$MT_VOLTAGE,$MT_TEMP,$MT_UPTIME,$MT_CPU_LOAD,$SERVER_TIME,$ROUTER_MAC,$MESH_NEIGHBOR_COUNT_2G,$MESH_CLUSTER,$MAC,$ROOT_PORT,$ROOT_PATH_COST,$DESIGNATED_BRIDGE,$DESIGNATED_COST,$IP2,$DESIGNATED_BRIDGE_SIGNAL,timestamp_corrected,$MT_STARTUP_COUNT' > ~/evr-indicators/$LOGFILE_PATH/indicators-header.txt 
echo $CSV_VERSION,$IP,$NAME,$TIMESTAMP,$MACS,$SERIAL_NUMBER,$ROUTER_SERIAL,$ROUTER_MODEL,$PING_EXIT_CODE,$PING_DUPS,$PING_PACKET_LOSS,$PING_RRT_AVG,$HTTP_SPEED,$MESH_NEIGHBOR_COUNT,$STARTUP_COUNT,$CRASH_COUNT,$DMI_MODEL,$DISK_MODEL,$PARTITION_SIZE,$LINUX_VERSION,$UPTIME,$MT_VOLTAGE,$MT_TEMP,$MT_UPTIME,$MT_CPU_LOAD,$SERVER_TIME,$ROUTER_MAC,$MESH_NEIGHBOR_COUNT_2G,$MESH_CLUSTER,$MAC,$ROOT_PORT,$ROOT_PATH_COST,$DESIGNATED_BRIDGE,$DESIGNATED_COST,$IP2,$DESIGNATED_BRIDGE_SIGNAL,$MT_STARTUP_COUNT  >> ~/evr-indicators/$LOGFILE_PATH/indicators.xls

## Tracking serial number of hardware per site
echo $NAME,$TIMESTAMP, $SERIAL_NUMBER >> ~/evr-indicators/$LOGFILE_PATH/serial-number.xls
echo $TIMESTAMP,$ROUTER_SERIAL,$ROUTER_MODEL > ~/evr-indicators/$LOGFILE_PATH/Router_details.xls
echo $TIMESTAMP  $MESH_NB_SIGNAL_2G >> ~/evr-indicators/$LOGFILE_PATH/neibor-signa2.4G
echo $TIMESTAMP  $MESH_NB_SIGNAL_5G >> ~/evr-indicators/$LOGFILE_PATH/neibor-signa5.0G
#echo $TIMESTAMP $SCAN_CLUSTERS >> ~/evr-indicators/$LOGFILE_PATH/scan-clusters

# wait for 5 seconds to allow the data collection process to finalize before syncing the data with EVR server
sleep 5

/usr/bin/rsync -arv --append ~/evr-indicators/$LOGFILE_PATH user@192.168.21.254:~/evr-indicators

