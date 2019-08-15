#!/bin/sh
#
echo "Starting dowifiON.sh ..."
#
ifconfig iwm0 description "External WAN to outside via wifi-192.168.2.xxx"
ifconfig iwm0 inet -inet6 up
ifconfig iwm0 inet nwid hFeltonWifi2 wpakey 3900734777 
# ifconfig iwm0 groups wlan egress
# ifconfig iwm0 80211n
dhclient iwm0
#
echo "...dowifiON.sh complete."

