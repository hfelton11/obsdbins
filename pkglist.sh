#!/bin/sh
#         pkglist.sh - list MANUALLY added pkgs (minus fw)
#                      add -z to remove version-information
#
doas pkg_info -m|grep -v firmware
