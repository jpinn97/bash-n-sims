#!/bin/bash

declare -A user_data

while IFS=, read -r username role password pin || [[ -n $username ]]; do
    user_data["$username"]="$role,$password,$pin"
done < <(tail -n +2 ./data/UPP.db)

# Check if the key exists in the array and process accordingly
if [[ -n "${user_data[$1]}" ]]; then

    IFS=, read -r role password pin <<< "${user_data[$1]}"
    
    if [[ $2 == $password ]]; then
        exit 0
    else
        exit 13
    fi
else
    exit 13
fi
