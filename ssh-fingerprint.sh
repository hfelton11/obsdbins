#!/bin/sh
# this lists the www-host-keyfile-fingerprint...
ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub
