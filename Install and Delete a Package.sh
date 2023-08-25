#!/bin/bash

pathToPkg="/private/tmp/L02T03 - postinstall.sh.pkg"

/usr/sbin/installer -pkg "${pathToPkg}" -target /

rm "${pathToPkg}"