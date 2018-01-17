#!/bin/sh
#         pkglist.sh - list MANUALLY added pkgs (minus fw)
#
doas pkg_info -m|grep -v firmware
