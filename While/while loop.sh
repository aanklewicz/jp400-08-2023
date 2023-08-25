#!/bin/bash

while [[ -f /Users/Shared/chromeToDock.sh ]]
do
	echo "The file is still there."
	sleep 1
done

echo "The file is gone."