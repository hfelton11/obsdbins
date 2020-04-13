#!/bin/sh
#
# hjf latest mod: 2020-04-04 @ 09:30 PDT
#
## vidoas.sh
#
## this is a basic copy/update from eradman at
## http://eradman.com/posts/ut-shell-scripts.html
## PATTERN singleton try/assert()
## 
## GOAL try to create a vidoas pgm like visudo...
## ASSUMPTIONS interactive edits, allowing re-edits post-run, ...

export DOASFILE="/etc/doas.conf"
export TTY=`tty`
export USR=`whoami`
export VIDOAS=`basename $0`
export END_STRING="$VIDOAS: succeeded."
export TEST01=" doas-pw for initial copy..."
export TEST02=" edit of doas-file..."
export TEST03=" permissions of valid doas-file..."
export TEST04=" doas-pw for final replacement... "
export DEBUG_STRING=" \
1. incorrect $TEST01 \n \
2. incorrect $TEST02 \n \
3. incorrect $TEST03 \n \
4. incorrect $TEST04 \n"
export TESTING_STRING="Currently 4 possible tests: \n$DEBUG_STRING "
export DODEBUG=
export DONORMAL=1
export DOHELPFUL=
export START_STRING="$VIDOAS: MUST supply password before AND after edits..."
export XPLAINING_STRING="Password is normally required twice... \n \
 due to checks at Steps 1. and 4. from .... \n$DEBUG_STRING"

function setup { 
	export LAUNCH_CMDS=`mktemp`
	export VI_FILE=`mktemp`
} ; setup ;				# call self-setup...`
function teardown {
	rm -f $LAUNCH_CMDS
	rm -f $VI_FILE
}

# SINGLETON-setup
typeset -i test_runs=0
function try { this="$1"; }
trap 'printf "$0: exit code $? on line $LINENO\nFAIL: $this\n"; exit 1' ERR
function assert {
	let tests_run+=1
	[ "$1" = "$2" ] && { echo -n "."; return; }
	printf "\nFAIL: $this\n'$1' != '$2'\n"; teardown; exit 1
}

# MAIN-STARTS-HERE (assuming setup;)
#
#try "0. TESTING..."
[ "$DODEBUG" ] && { echo $TESTING_STRING; }
[ "$DOHELPFUL" ] && { echo $XPLAINING_STRING; }
[ "$DONORMAL" ] && { echo $START_STRING; }
#assert "`echo 't'`" "t"

#try "1. create an edit-able copy..."
try "1. $TEST01"
cat > $LAUNCH_CMDS <<-'LAUNCHER'
	doas -L
	doas cp $DOASFILE $VI_FILE
	doas -L
LAUNCHER
# fd/syserr catches bad passwords here...
assert "`. $LAUNCH_CMDS 2>&1`" ""

#try "2. go ahead and vi-edit ..."
try "2. $TEST02"
cat > $LAUNCH_CMDS <<-'LAUNCHER'
# dont let kshrc-stuff run...
	export ENV=''
	( sh -i -c "vi $VI_FILE <$TTY >$TTY" )
	doas -C $VI_FILE 
LAUNCHER
# check for syntax errors from editting...
assert "`. $LAUNCH_CMDS 2>&1`" ""

#try "3. post-edit-check for replacement permissions..."
try "3. $TEST03"
assert "`doas -C $VI_FILE -u $USR cp | cut -c 1-6 `" "permit"

#try "4. install the latest-greatest back..."
try "4. $TEST04"
assert "`doas cp $VI_FILE $DOASFILE 2>&1`" ""

# MAIN-ENDS-HERE....
#
#try "999. Testing ENDS..."
[ "$DODEBUG" ] && { echo; echo "PASS: $tests_run tests run"; }
[ "$DOHELPFUL" ] && { echo; echo "All $tests_run steps ok, so..."; echo $END_STRING; }
[ "$DONORMAL" ] && { echo $END_STRING; }
#assert "`echo 't'`" "t"
##echo "vidoas.sh succeeded."
teardown; exit 0

