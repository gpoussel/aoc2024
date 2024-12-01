#!/bin/bash

left=()
right=()

while read line; do
    IFS=' ' read -r -a array <<< "$line"
    left+=(${array[0]})
    right+=(${array[1]})
done

IFS=$'\n'
sorted_left=($(sort <<<"${left[*]}"))
sorted_right=($(sort <<<"${right[*]}"))
unset IFS

sum_diff=0
for i in $(seq 0 $((${#sorted_left[@]} - 1))); do
    # Absolute difference between the two numbers
    diff=$((${sorted_left[$i]} - ${sorted_right[$i]}))
    sum_diff=$(($sum_diff + ${diff#-}))
done

echo "Part 1: $sum_diff"


sum_similarity=0
for i in $(seq 0 $((${#sorted_left[@]} - 1))); do
    occurrences=$(printf '%s\n' ${sorted_right[*]} | grep -cFx ${sorted_left[$i]})
    similarity=$((${sorted_left[$i]} * $occurrences))
    sum_similarity=$(($sum_similarity + $similarity))
done

echo "Part 2: $sum_similarity"
