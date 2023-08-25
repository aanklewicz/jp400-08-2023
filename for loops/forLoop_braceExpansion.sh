#!/bin/bash

ids=$(echo {1..100})

#echo $ids

for i in $ids
do
	echo "This is where I would use a GET command with Jamf Pro Server $i"
	sleep .2
done