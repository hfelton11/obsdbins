#!/bin/sh
echo "Starting doCVSallUP.sh..."
cd /usr
cvs -qd anoncvs@anoncvs1.usa.openbsd.org:/cvs up -Pd -rOPENBSD_6_5 src
echo "...src-done start-xenocara..."
cvs -qd anoncvs@anoncvs1.usa.openbsd.org:/cvs up -Pd -rOPENBSD_6_5 xenocara
echo "...xenocara-done start-ports..."
cvs -qd anoncvs@anoncvs1.usa.openbsd.org:/cvs up -Pd -rOPENBSD_6_5 ports
echo "...ports-done start-www..."
# had to use git here...
#cd /usr/www/GIT
#git clone https://github.com/openbsd/www.git
#cd www ;git branch hjflocal ;git checkout hjflocal
cd /usr/www/GIT/www
#git checkout master ;git pull ;git checkout hjflocal
git pull origin master
echo "... doCVSallUP.sh done."

