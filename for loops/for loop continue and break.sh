#!/bin/bash

# Out loops have special keywords like continue and break
# continue will continue through the remaining items, but ignore the current one
# break will stop the loop

for folder in /System/*
do
	if [[ "$(basename $folder)" = "Volumes" ]] 
	then
		continue
	fi
	echo "$(basename $folder)"
done