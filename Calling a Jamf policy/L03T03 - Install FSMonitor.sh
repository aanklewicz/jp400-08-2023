#!/bin/bash

if [[ -d /Applications/FSMonitor.app/ ]]
then
	# /usr/local/jamf/bin/jamf policy -trigger chromeDock
	echo "FSMonitor already installed"
	exit 0
else
	/usr/local/jamf/bin/jamf policy -trigger InstallFSMonitor
	echo "FSMonitor has been installed"
	exit 0
fi