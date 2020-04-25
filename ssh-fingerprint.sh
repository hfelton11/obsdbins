#!/bin/sh
# the FULL list of POSSIBLE fingerprints is...
ssh-keygen -l -f /etc/ssh/ssh_host_dsa_key.pub
ssh-keygen -l -E md5 -f /etc/ssh/ssh_host_dsa_key.pub
ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub
ssh-keygen -l -E md5 -f /etc/ssh/ssh_host_ecdsa_key.pub
ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub
ssh-keygen -l -E md5 -f /etc/ssh/ssh_host_ed25519_key.pub
ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub
ssh-keygen -l -E md5 -f /etc/ssh/ssh_host_rsa_key.pub
