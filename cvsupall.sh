#!/bin/sh
cd /usr &&  cvs -q up -Pd src 
[ $? ] && exit 1
cd /usr &&  cvs -q up -Pd xenocara
[ $? ] && exit 1
cd /usr &&  cvs -q up -Pd ports
[ $? ] && exit 1
echo "src ports and xenocara updated, located in `pwd`"
exit 0
