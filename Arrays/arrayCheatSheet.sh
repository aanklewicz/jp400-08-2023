#!/bin/bash

myArray=("Saul" "Kim" "Nacho")

# echo with array syntex to get all values in the array with the @ symbol
echo "${myArray[@]}"

# echos the total count of items in myArray[@]
echo "${#myArray[@]}"

myArray+=("Mike" "Sam")

echo "${myArray[@]}"
echo "${#myArray[@]}"