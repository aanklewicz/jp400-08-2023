#!/bin/bash

read -p "Please enter the word true: " response

if [[ "$response" =~ ^[1T]$|^[Tt][rR][uU][eE]$ ]]; then
	echo "Thank you. That is true."
else
	echo "That is not true."
fi
