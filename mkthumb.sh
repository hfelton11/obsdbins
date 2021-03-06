#!/bin/sh
# tested on OpenBSD 6.5 with ksh...
# this assumes imagemagick is avail...
# this assumes your cwd() has all *.jpg (and this script),
#   while also containing a (hopefully empty) thumbnails dir...
# creates 100px-wide thumbs converting *.jpg to *.png
#   assuming no fancy-names like IMG.ohoh.ohoh2.jpg...

for f in *.jpg; do
  convert $f -strip -thumbnail x100 thumbnails/${f%.*}.png
done
