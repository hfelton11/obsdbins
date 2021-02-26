#!/bin/sh
# cvsup.sh
dts=`date +%Y%m%d-%H%M%S`
for d in {src,xenocara,ports,www}; do
        echo "updating /usr/$d..."
        cd /usr/$d
        cvs -q up -Pd -A > ~/cvsup-$d-$dts.log 2>cvsup-$d-$dts.err
        if [ $? ]; then rm ~/cvsup-$d-$dts.log; fi
done
echo "... finished updates."
echo
ls -alFh ~/cvsup*.err
echo -n "if errors were only 'cvs server: .... is no longer in the repository'"
echo " messages, then maybe rerun this command to confirm no further removals."

