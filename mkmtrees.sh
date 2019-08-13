#!/bin/ksh
#
# hjf last mod: 2019-08-13 13:30 PDT
#
# mkmtrees.sh
#
# create default mtrees for trojan-catching...

export MKMTREEPATHS="/bin /sbin /usr/bin /usr/sbin"
export FNDIR="/etc/mtree"
export FNTYP="secure"
export FNOWN="root:wheel"
export FNMOD="600"
# final cksum cmd --AND-- intermediate digests
export SHA256="sha256"
# seconds since epoch-UTC
export TODAY=`date +"%s"`
export TMPLOC=`mktemp`
export TMPNAMS=`mktemp`
export TMPCKSUM=`mktemp`

for ITEM in $MKMTREEPATHS; do
	# remove-or-xlate / for filename
	FN=`echo "$ITEM"|sed -e s:/:: -e s:/:_:g`
	FNFULL="$FNDIR/$FN.$FNTYP"
	echo "$FNFULL" >> $TMPNAMS
	echo "making mtree for $ITEM --> $FNFULL (epoch: $TODAY)"
	CMD="mtree -cix -p $ITEM -K ${SHA256}digest,type "
	doas $CMD > $TMPLOC 
	doas cp -fp $TMPLOC $FNFULL
	doas chown $FNOWN $FNFULL
	doas chmod $FNMOD $FNFULL
done
FNLIST=`cat $TMPNAMS`
doas $SHA256 $FNLIST > $TMPCKSUM
FINALCKSUM="$FNDIR/$SHA256_$TODAY.fullcksum"
doas cp -fp $TMPCKSUM $FINALCKSUM
doas chown $FNOWN $FINALCKSUM
doas chmod 444 $FINALCKSUM
#echo "$0 complete: master cksums stored at $FINALCKSUM"
echo "mkmtrees.sh done... : master cksums stored at $FINALCKSUM"
