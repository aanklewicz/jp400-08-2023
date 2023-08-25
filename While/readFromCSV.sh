#!/bin/bash

IFS=,

while read bldgnum bldgname extra
do
	if [[ $bldgnum = "BldgNumber"  ]]
	then
		continue
	fi
	echo "Creating building $bldgname ($bldgnum) ..."
done < ~/Desktop/buildings.csv