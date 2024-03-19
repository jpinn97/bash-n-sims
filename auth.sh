#!/bin/ash

# Read the JSON file and process it
user_data=$(cat ./data/UPP.json)

# Function to get user data from the JSON
get_user_data() {
    username="$1"
    echo "$user_data" | jq -r ".users.${username}"
}

# Check if the user exists and process accordingly
user_info=$(get_user_data "$1")

# If the user exists, check the role and password
if [ -n "$user_info" ]; then
    role=$(echo "$user_info" | jq -r '.role')
    password=$(echo "$user_info" | jq -r '.password')

    if [ "$2" = "$password" ]; then
        if [ "$role" -eq 0 ]; then
            exit 0
        elif [ "$role" -eq 1 ]; then
            exit 1
        fi
    else
        exit 13
    fi
else
    exit 13
fi
