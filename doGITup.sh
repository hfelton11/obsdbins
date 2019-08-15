#!/bin/sh
echo "Starting doCVSallUP.sh..."
#
# choosing to do all of these via git, since faster/easier than cvs...
cd /xtra/src/GIT/src
git pull origin master
echo "...src-done start-xenocara..."
cd /xtra/xenocara/GIT/xenocara
git pull origin master
echo "...xenocara-done start-ports..."
cd /xtra/ports/GIT/ports
git pull origin master
echo "...ports-done start-www..."
cd /xtra/www/GIT/www
git pull origin master
echo "... doCVSallUP.sh done."

