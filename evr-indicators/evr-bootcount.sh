#!/bin/bash

# crash detection based on rsyslogd
# example of ordinary restart from Lubuntu 15.4, crashes do not have the first line
# Nov 24 16:20:12 xian-VirtualBox rsyslogd: [origin software="rsyslogd" swVersion="7.4.4" x-pid="426" x-info="http://www.rsyslog.com"] exiting on signal 15.
# Nov 24 16:26:58 xian-VirtualBox rsyslogd: [origin software="rsyslogd" swVersion="7.4.4" x-pid="433" x-info="http://www.rsyslog.com"] start

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# create count files if necessary
if [ ! -f $SCRIPTPATH/evr-bootcount.log ]; then
    echo "0" > $SCRIPTPATH/evr-bootcount.log
fi
if [ ! -f $SCRIPTPATH/evr-crashcount.log ]; then
    echo "0" > $SCRIPTPATH/evr-crashcount.log
fi

echo $[$(</home/user/evr-indicators/evr-bootcount.log)+1] > /home/user/evr-indicators/evr-bootcount.log

# search all first messages after startup plus the line before
grep -B 1 'x-info="http://www.rsyslog.com"] start' /var/log/syslog | tail -2 > /home/user/evr-indicators/evr-startup.log
# check if rsyslogd properly exited on signal 15, if not then assume a crash
grep 'x-info="http://www.rsyslog.com"] exiting on signal 15.' /home/user/evr-indicators/evr-startup.log
if [ $? -ne 0 ]; then
	# no proper rsyslogd shutdown, assuming crash and increase counter
	touch /home/user/evr-indicators/evr-crashcount.log
	echo $[$(</home/user/evr-indicators/evr-crashcount.log)+1] > /home/user/evr-indicators/evr-crashcount.log
fi
rm /home/user/evr-indicators/evr-startup.log
