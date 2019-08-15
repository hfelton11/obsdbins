#!/bin/sh
#
echo "Starting startX.sh ..."
#
xenodm -server ":0 local /usr/X11R6/bin/X :0"
#
echo "...startX.sh complete."

