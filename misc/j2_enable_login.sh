#!/bin/bash


MT_IP=$1

J2_IP=`ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no admin@$1 "/ip dhcp-server lease print" | grep J2 | awk '{print $3}'`
ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no admin@$1 "ping count=2 $J2_IP"

sleep 5

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -nNT -L 2222:$J2_IP:22 admin@$MT_IP

