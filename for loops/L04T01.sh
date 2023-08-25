#!/bin/bash

IFS=,

for folder in /System/Applications/*.app
do
	if [[ $(basename "$folder") == "Contacts.app" ]] 
	then
		continue
	fi
	echo -n "$(basename $folder) version "
	defaults read ${folder}/Contents/Info.plist CFBundleShortVersionString
done