#!/bin/bash

myArray=()

until [[ "${#myArray[@]}" -gt 4 ]]
do
	read -p "Please enter a building name: " name
	myArray+=("$name")
done

echo -n "${#myArray[@]} buildings, and they are: "
echo "${myArray[@]}"