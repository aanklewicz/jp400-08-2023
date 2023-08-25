#!/bin/bash

# -d is to see if a directory exists. .apps are not files, but directories

if [[ -d /Applications/Google\ Chrome.app ]]
then
	/usr/local/jamf/bin/jamf policy -trigger chromeDock
fi