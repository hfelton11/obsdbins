#!/bin/sh
#
tmpdir=""
machine=$(uname -m)
wherein="snapshots"
if [ z"$1" == z ]; then
	echo 'no first-arg bypass...'
elif [ z"$1" == "z-h" ]; then
	echo "Usage: $0 <args>"
	echo "     any arguments supplied will cause the pgm to"
	echo "     assume you have INTERNALLY specified the temporary"
	echo "     directory and filelist-file in this program..."
	echo "otherwise, all files are stored in 'mktemp' areas which"
	echo "     will NOT survive a reboot unless copied elsewhere..."
	echo "-r61 is MAGIC and grabs the release-dir for 6.1"
	echo "-r62 is MAGIC and grabs the release-dir for 6.2"
	echo "-r63 is MAGIC and grabs the release-dir for 6.3"
	echo "-r64 is MAGIC and grabs the release-dir for 6.4"
	echo
	exit 0
elif [ z"$1" == "z-r61" ]; then
	wherein="6.1"
elif [ z"$1" == "z-r62" ]; then
	wherein="6.2"
elif [ z"$1" == "z-r63" ]; then
	wherein="6.3"
elif [ z"$1" == "z-r64" ]; then
	wherein="6.4"
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
ftpstart="$mirror"/"$wherein"/"$machine"
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
	cat "$hash" | cut -d ' ' -f 2 -s SHA256 | \
sed s/\(// | sed s/\)// | grep -v -e '.fs' -e '.iso' > "$fnames"
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
if [ $wherein == "-r61" ]; then
	key2="/etc/signify/openbsd-61-base.pub"
fi
if [ $wherein == "-r62" ]; then
	key2="/etc/signify/openbsd-62-base.pub"
fi
if [ $wherein == "-r63" ]; then
	key2="/etc/signify/openbsd-63-base.pub"
fi
if [ $wherein == "-r64" ]; then
	key2="/etc/signify/openbsd-64-base.pub"
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
