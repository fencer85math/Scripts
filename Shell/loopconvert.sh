#!/bin/bash

#
# Convert the for loops in Example 11-1 to while loops
# HINT: store the date in an array and step through the array loops
# Then convert the loops into until loops

# For Loop
for planet in Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto
do
  echo $planet 
done

echo; echo

for planet in "Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto"
do
	echo $planet
done

echo; echo "Whoops! Pluto is no longer a planet!"

# While Loop
planetslist=( Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto )
planetslistsize=${#planetslist[@]}
i=0

while [ $i -lt $planetslistsize ]
do
	echo ${planetslist[$i]}
	i=`expr $i + 1 `
done

echo; echo "While: Whoops! Pluto is no longer a planet!"

# Until Loop

planetslist=( Mercury Venus Earth Mars Jupiter Saturn Uranus Neptune Pluto )
planetslistsize=${#planetslist[@]}
i=0

until [ $i -eq $planetslistsize ]
do
	echo ${planetslist[$i]}
	i=`expr $i + 1 `
done

echo; echo "Until: Whoops! Pluto is no longer a planet!"
