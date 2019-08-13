#!/bin/ksh
#
# hjf last mod: 2019-08-13 07:30 PDT
#
# mkmtrees.sh
#
# create default mtrees for trojan-catching...

export MKMTREEPATHS="/bin /sbin /usr/bin /usr/sbin"
export MATCHNAMES="bin sbin usr_bin usr_sbin"
export FNDIR="/etc/mtree"
export FNTYP="secure"
export FNOWN="root:wheel"
export FNMOD="600"
export TMPLOC=`mktemp`

for ITEM in $MKMTREEPATHS; do
	# remove / for filename
	FN=`echo "$ITEM"|sed -e s:/:: -e s:/:_:g`
	FNFULL="$FNDIR/$FN.$FNTYP"
	echo "$ITEM --> $FNFULL"
	doas mtree -cix -p $ITEM -K sha256digest,type > $TMPLOC
	doas cp -fp $TMPLOC $FNFULL
	doas chown $FNOWN $FNFULL
	doas chmod $FNMOD $FNFULL
done
# how to "fix" the mod-time on direc itself...
#doas mtree -df /etc/mtree/bin.secure -t -p /bin/\.
# afterwards, take digest-of-digest-file for offsite safekeeping...
# before-wards, reset all dirs to read-only ?
# howto set touch-fixups for changes from syspatch, etc...
