#!/bin/sh
#
echo "Starting killwifi.sh ..."
#
ifconfig iwm0 -inet -inet6 -nwid -bssid -chan down
#
echo "...killwifi.sh complete."

