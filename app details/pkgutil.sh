#!/bin/bash

recentXProtect=$(pkgutil --pkgs=".*XProtectPlist.*" | sort -n | tail -1)

# echo $recentXProtect

timeStamp=$(pkgutil --pkg-info "$recentXProtect" | awk '/install-time/{print $2}')

echo "<results>$(date -jf %s $timeStamp '+%F %T')</results>"