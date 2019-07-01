#!/bin/sh
#
# hjf latest mod: 2019-07-01 @ 03:10
#
## readme_bootstrap.txt.sh
#
## this assumes "pkg_add -i stow" is avail...
## this assumes that you are currently in PARENT
## and that there is a CHILD-dir called obsdbins
## and within obsdbin, you want everything symlinked
## into your normal ~/bin directory...
#
#pwd     ## PARENT
#ls -l   ## child listing has obsdbins
#ls ~/bin  ## you have a basically-empty bin-dir...
#
## run this to be SURE it will work...
#stow -nv  -t ~/bin -S obsdbins/
#
## obv. run it again without the -n option...
echo "stow -nv  -t ~/bin -S obsdbins/"
stow -nv  -t ~/bin -S obsdbins/
