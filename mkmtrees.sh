#!/bin/ksh
#
# hjf last mod: 2020-04-12 19:30 PDT
#
# mkmtrees.sh
#
# create default mtrees for trojan-catching...

export MKMTREEPATHS="/bin /sbin /usr/bin /usr/sbin"
export FNDIR="/etc/mtree"
export FNTYP="secure"
export FNOWN="root:wheel"
export FNMOD="600"
# intermediate digests --AND-- final cksum cmd 
export SHA256="sha256"
#export CMD="mtree -cix -p $ITEM -K ${SHA256}digest,type "
# seconds since epoch-UTC
export TODAY=`date +"%s"`
# temp-files, as needed...
export TMPLOC=`mktemp`
export TMPNAMS=`mktemp`
export TMPCKSUM=`mktemp`

export HELPMSG="\n \
hopefully this was called via: \
'doas -u mkmtrees mkmtrees.sh' \
 or similar... \n \
because calling-user will want \
persist or nopass doas-options... \n"

echo $HELPMSG;

for ITEM in $MKMTREEPATHS; do
	# remove-or-xlate / for filename
	FN=`echo "$ITEM"|sed -e s:/:: -e s:/:_:g`
	FNFULL="$FNDIR/$FN.$FNTYP"
	echo "$FNFULL" >> $TMPNAMS
	echo "making mtree for $ITEM --> $FNFULL (epoch: $TODAY)"
	CMD="mtree -cix -p $ITEM -K ${SHA256}digest,type "
	doas $CMD > $TMPLOC 
	# really need/want persist-doas...
	doas cp -fp $TMPLOC $FNFULL
	doas chown $FNOWN $FNFULL
	doas chmod $FNMOD $FNFULL
done

echo "mtree loops complete..."
FNLIST=`cat $TMPNAMS`
doas $SHA256 $FNLIST > $TMPCKSUM
FINALCKSUM="$FNDIR/${SHA256}_$TODAY.fullcksum"
doas cp -fp $TMPCKSUM $FINALCKSUM
doas chown $FNOWN $FINALCKSUM
doas chmod 444 $FINALCKSUM

rm -f $TMPLOC
rm -f $TMPNAMS
rm -f $TMPCKSUM

#echo "$0 complete: master cksums stored at $FINALCKSUM"
echo "mkmtrees.sh done... : master cksums stored at $FINALCKSUM"
