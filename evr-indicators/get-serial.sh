#!/bin/bash

/usr/sbin/dmidecode -t system  | grep Serial | awk '{print $3}' > /home/user/evr-indicators/serial

