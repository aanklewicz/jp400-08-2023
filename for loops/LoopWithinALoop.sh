#!/bin/bash

for server in class exam
do
	echo "$server
===========
"
	
	
	for ((i=1;i<15;i++))
	do
		if [[ $i -eq 3 ]] || [[  $i -eq 9 ]]
		then 
			continue 
		fi
		echo -n "https://a400-${i}a.pro.jamf.training/ Status: " # doesn't show return after echo
		curl -s "https://a400-${i}a.pro.jamf.training/healthCheck.html"
	done
done