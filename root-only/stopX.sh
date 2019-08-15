#!/bin/sh
#
echo "Starting stopX.sh ..."
#
#ps -A | grep x[e]nodm 
#ps -A | grep x[e]nodm | grep lo[c]al
## needed TWO because of pid being ' 357' instead of '4678'...
#ps -A | grep x[e]nodm | grep lo[c]al | cut -d ' ' -f -2 
#ps -A | grep x[e]nodm | grep lo[c]al | cut -d ' ' -f -2 \
# | xargs -rt kill  
## better version???
#ps -Au 
ps -Au | grep x[e]nodm | grep lo[c]al | awk '{print $2}' \
 | xargs -rt kill  
##
echo "...stopX.sh complete."

