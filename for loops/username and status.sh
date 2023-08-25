#!/bin/bash

listOfUsers=$(dscl . list /Users Password | awk '$2=="********"{print $1}')

# echo "$listOfUsers"

for username in $listOfUsers; do
	echo -n "$username "
	
	sysadminctl -secureTokenStatus "$username" 2>&1 | awk '{print $7}' | tr [[:upper:]] [[:lower:]]
done