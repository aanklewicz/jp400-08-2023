#!/bin/bash

bldgs=()
bldgs+=("Cafe Tropical" "Bob's Garage")
bldgs+=("Rose Apothecary" "Blouse Barn")
bldgs+=("Rosebud Motel")

# echo "${bldgs[@]}"

 echo "BldgNumber,Bldg Name,EmployeeCount" > ~/Desktop/buildings.csv

for((index=0;index<${#bldgs[@]};index++))
do
	echo "$index,${bldgs[$index]},$RANDOM" >> ~/Desktop/buildings.csv
done