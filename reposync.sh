# reposync.sh
#
cd /var/xxx-extras/reposync
doas -u reposync reposync rsync://anoncvs1.usa.openbsd.org/cvs cvs
