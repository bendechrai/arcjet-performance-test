#!/bin/bash

# Read input data
input=$(cat)

# Find all lines starting with "Test: " or "Time per request: "
# Exclude lines ending with "across all concurrent requests)"
# Remove the "Test: " or "Time per request: " prefix
# Remove the units after the time
lines=$(
    echo "$input" |
        grep -E '^Test: |^Time per request: ' |
        grep -v 'across all concurrent requests)' |
        sed -E 's/^Test: //; s/^Time per request: //; s/ \[ms\] \(mean\)//; s/^ *//; s/ *$//'
)

# Print the lines in pairs
odd=1
while read -r line; do
    if [ $odd -eq 1 ]; then
        echo -n "$line, "
        odd=0
    else
        echo "$line"
        odd=1
    fi
done <<<"$lines"
