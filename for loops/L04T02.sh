#!/bin/bash

IFS=,

array=()
array+=("Your Mom" "Your Dad" "Work" "Home" "I'm Bored")

for i in ${array[@]}
do
	echo $i
done