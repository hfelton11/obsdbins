#!/bin/ksh
#
# hjf latest mod: 2019-08-05 @ 10:00
#
## vidoas.sh
#
## this is a basic copy/update from eradman at
## http://eradman.com/postst/ut-shell-scripts.html
## 
## GOAL try to create a vidoas pgm like visudo...

export LAUNCH_CMDS=`mktemp`
export VI_FILE=`mktemp`
export USR=`whoami`
export TTY=`tty`
export DOASFILE="/etc/doas.conf"


typeset -i test_runs=0
function try { this="$1"; }
trap 'printf "$0: exit code $? on line $LINENO\nFAIL: $this\n"; exit 1' ERR
function assert {
	let tests_run+=1
	[ "$1" = "$2" ] && { echo -n "."; return; }
	printf "\nFAIL: $this\n'$1' != '$2'\n"; exit 1
}

try "1. create an edit-able copy..."
cat > $LAUNCH_CMDS <<-'LAUNCHER'
	doas -L
	doas cp $DOASFILE $VI_FILE
	doas -L
LAUNCHER
# syserr catches bad passwords here...
assert "`. $LAUNCH_CMDS 2>&1`" ""

try "2. go ahead and vi-edit ..."
cat > $LAUNCH_CMDS <<-'LAUNCHER'
# dont let kshrc-stuff run...
	export ENV=''
	( ksh -i -c "vi $VI_FILE <$TTY >$TTY" )
	doas -C $VI_FILE 
LAUNCHER
# check blatant errors in editting...
assert "`. $LAUNCH_CMDS 2>&1`" ""

try "3. post-edit-check for replacement permissions..."
assert "`doas -C $VI_FILE -u $USR cp | cut -c 1-6 `" "permit"

try "4. install the latest-greatest back..."
assert "`doas cp $VI_FILE $DOASFILE 2>&1`" ""


rm -f $LAUNCH_CMDS
rm -f $VI_FILE

##echo; echo "PASS: $tests_run tests run"
echo "vidoas.sh succeeded."

