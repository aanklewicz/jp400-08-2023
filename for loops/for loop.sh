#!/bin/bash

#for i in red orange yellow green blue indigo violet
#do
#	echo "The colour is $i"
#	sleep .5
#done

#colours="red orange yellow green blue indigo violet"
#for i in $colours
#do
#	echo $i
#	sleep .5
#done

# Defaults field separator is a space, you must define the internal field separator (IFS) if you wish to use another mothod.
IFS=,

colours="red,orange,yellow,light green,blue,indigo,violet"
for i in $colours
do
	echo $i
	sleep .5
done