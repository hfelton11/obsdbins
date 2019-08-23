#!/bin/sh
#
tmpdir=""
machine=$(uname -m)
wherein="snapshots"
pkeys="latest"
if [ z"$1" == z ]; then
	echo 'no first-arg bypass...'
elif [ z"$1" == "z-h" ]; then
	echo "Usage: $0 <args>"
	echo "     any arguments supplied will cause the pgm to"
	echo "     assume you have INTERNALLY specified the temporary"
	echo "     directory and filelist-file in this program..."
	echo "otherwise, all files are stored in 'mktemp' areas which"
	echo "     will NOT survive a reboot unless copied elsewhere..."
	echo "-fw is MAGIC and grabs the snapshot-firmware files"
	echo "-r61 is MAGIC and grabs the release-dir for 6.1"
	echo "-r62 is MAGIC and grabs the release-dir for 6.2"
	echo "-r63 is MAGIC and grabs the release-dir for 6.3"
	echo "-r64 is MAGIC and grabs the release-dir for 6.4"
	echo "-r65 is MAGIC and grabs the release-dir for 6.5"
	echo "-r66 is MAGIC and grabs the release-dir for 6.6"
	echo
	exit 0
elif [ z"$1" == "z-fw" ]; then
	do_FW="1"
	pkeys="66"
elif [ z"$1" == "z-r61" ]; then
	wherein="6.1"
	pkeys="61"
elif [ z"$1" == "z-r62" ]; then
	wherein="6.2"
	pkeys="62"
elif [ z"$1" == "z-r63" ]; then
	wherein="6.3"
	pkeys="63"
elif [ z"$1" == "z-r64" ]; then
	wherein="6.4"
	pkeys="64"
elif [ z"$1" == "z-r65" ]; then
	wherein="6.5"
	pkeys="65"
elif [ z"$1" == "z-r66" ]; then
	wherein="6.6"
	pkeys="66"
else
	tmpdir=/home/hfeltonadmin/snaps/s20171009
	#tmpdir=/tmp/tmp.Q7s73OF7OI
	tmpfns=/tmp/tmp.c7ibPuZy1s
	echo 'using "$tmpdir" and "$tmpfns" ...'
fi
#
# move to temporary-area (given or newly-created)
#
if [ -d "$tmpdir" ]; then
	cd "$tmpdir"
else
	cd $(mktemp -d)
	tmpdir=`pwd`
	tmpfns='tmp.filenames'
fi
if [ -f /etc/installurl ]; then
	< /etc/installurl read mirror
else
	mirror=https://ftp3.usa.openbsd.org/pub/OpenBSD
fi
#
# everything relies on SHA256-hashes being good...
# -s means file is NOT-empty (has Size)
# [[ uses && instead of -a for ANDing
#
hash=SHA256
if [[ -s $hash && -s ${hash}.sig ]]; then
	true
else
	echo '...hashes bad, so ignoring "$tmpfns" ...'
	tmpfns=""
fi
if [ -n "$do_FW" ]; then
	ftpstart="http://firmware.openbsd.org/firmware"/"$wherein"
else
	ftpstart="$mirror"/"$wherein"/"$machine"
fi
#
# -f means file is regular (and exists)
# -n, -z apply to STRINGs
# -r would be readable (even socket/block-special/...)
#
if [ -f "$tmpfns" ]; then
	fnames="$tmpfns"
else
	ftp 	"$ftpstart"/"$hash"{.sig,}
	fnames=$(mktemp)
	##if [ "X$do_FW" = X  ]; then
		cat "$hash" | cut -d ' ' -f 2 -s SHA256 | \
		sed s/\(// | sed s/\)// |  \
		grep -v -e '.fs' -e '.iso' > "$fnames"
	##fi
fi
#
# strip out iso/fs duplicates
#
cat "$fnames" | paste -d ',' -s -
fnlist=$(paste -s $fnames)
# 
for fn in $fnlist; do
#	echo "fn is $fn"
	if [ ! -f "$fn" ]; then
		ftp 	"$ftpstart"/"$fn"
	fi
done
#
key1=$(ls /etc/signify/openbsd-??-base.pub | tail -2 | head -1)
key2=$(ls /etc/signify/openbsd-??-base.pub | tail -2 | tail -1)
#echo "key1=$key1"
#echo "key2=$key2"
# hack for -r61, while snaps are -62 and -63 (now during rc-time)
# however, if we want an OLD release, we need this hack also...
#if [ $wherein == "-r61" ]; then
#	key2="/etc/signify/openbsd-61-base.pub"
#fi
if [ $pkeys != "latest" ]; then
	##key2="/etc/signify/openbsd-$pkeys-base.pub"
	if [ -n "$do_FW" ]; then
		key2="/etc/signify/openbsd-$pkeys-fw.pub"
	else
		key2="/etc/signify/openbsd-$pkeys-base.pub"
	fi
fi
cmdsigBeg="signify -C -q -p "
cmdsigEnd=" -x ${hash}.sig "
#dmpErr=" 2> /dev/null "
#retstr=
retfull=
for fn in $fnlist; do
	retstr=""
	$($cmdsigBeg $key1 $cmdsigEnd $fn 2>/dev/null) 
	if [ $? -ne 0 ]; then
		retstr="Bad check on $fn"
#		echo $retstr
	fi
# 
# fails ONLY if BOTH old/current signify-tests fail...
#
	$($cmdsigBeg $key2 $cmdsigEnd $fn 2>/dev/null)     
	if [[ $? -ne 0  &&  $retstr != "" ]]; then
		retstr="\nBad check2 on $fn"
		echo $retstr
		# FULL Failure...
		retfull="1"
	else
		# kluge for debugging...
		retstr="$fn is ok"
		echo -n $retstr,
	fi
done
#
# these are as-good-as-can-be...
#
if [ X"$retfull" == X ]; then
	echo "\n"
	echo "finished $0 w/files in $tmpdir..."
fi
