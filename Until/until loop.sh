#!/bin/bash

read -p "Please enter your desired temperature in ºF " ovenTemp

currentTemp=70

until [[ "$currentTemp" -ge "$ovenTemp" ]]
do
	echo "$currentTemp ºF"
	currentTemp=$((currentTemp+5))
	sleep .25
done

echo "The temperature has reached $ovenTemp ºF, preheating is done."