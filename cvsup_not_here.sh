#!/bin/ksh
# cvsup.sh
for d in {src,xenocara,www,ports}; do
  cd /usr/$d
  cvs -q up -Pd -A
done
cd
