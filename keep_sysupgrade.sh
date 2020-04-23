#!/bin/sh
# keep_sysupgrade.sh
#
DTS=`date +"%Y%m%d-%H%M"`
#DTS=`date +"%Y%m%d"`
NEWDIR="sysup-${DTS}"
DIRNM="/home/_sysupgrade"
CHKNM="${DIRNM}/keep"

cd /home/hfeltonadmin/sysupgrade_keeps
if [ -e $CHKNM ]; then
	mkdir $NEWDIR
	# note: "${DIRNAM}/*" would protect shell-expansion of *
	cp -p ${DIRNM}/* $NEWDIR
fi
