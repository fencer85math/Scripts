#!/bin/bash

MAX=10000

  for((nr=1; nr<$MAX; nr++))
  do

    let "t1 = nr % 5"
    echo "$nr .. $t1 .. $t2 .. $t3"
    if [ "$t1" -ne 3 ]
    then
      continue
    fi

    let "t2 = nr % 7"
    echo "$nr .. $t2 .. $t3"
    if [ "$t2" -ne 4 ]
    then
      continue
    fi

    let "t3 = nr % 9"
    echo "$nr .. $t3"
    if [ "$t3" -ne 5 ]
    then
      continue
    fi

  break # What happens when you comment out this line? Why?
  # the answer is nr is 10000; with breaking the loop,

  done

  echo "Number = $nr"

exit 0
