#!/bin/ksh
# mknu.sh - make a passwordless new-user...

USAGE="Usage $0 NewUserName ...\n"
NORIGHTS="Your user does not have doas-rights to useradd-cmd.\n"
IAM=`whoami`

if [ "X$1" == X ]; then echo $USAGE; exit 0; fi
doas useradd -m $1
if [ ! $? ]; then echo $NORIGHTS; exit 0; fi
doas sh -c ' echo "permit nopass keepenv $IAM as $1" >> /etc/doas.conf '
echo "$1 user added..."
exit 0
