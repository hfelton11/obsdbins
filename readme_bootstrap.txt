# hjf latest mod: 2017-10-07 @ 03:10
#
# readme_bootstrap.txt

# this assumes that you are currently in PARENT
# and that there is a CHILD-dir called obsdbins
# and within obsdbin, you want everything symlinked
# into your normal ~/bin directory...

pwd     ## PARENT
ls -l   ## child listing has obsdbins
ls ~/bin  ## you have a basically-empty bin-dir...

# run this to be SURE it will work...
stow -nv  -t ~/bin -S obsdbins/

# obv. run it again without the -n option...
