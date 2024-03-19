#!/bin/ash

# shellcheck disable=SC1091
. ./library.sh

# Load the entire JSON file into a variable
user_data=$(retrieve_user_data)

check_user_exists() {
    user="$1"
    result=$(echo "$user_data" | jq -r ".users | has(\"$user\")")
    if [ "$result" = "true" ]; then
        return 0
    else
        return 1
    fi
}

total_time_by_user() {
    user=$1
    local time=0
    while IFS= read -r line; do
        if echo "$line" | grep -q "User: $user, Action: Session:"; then
            time="$((time + $(echo "$line" | cut -d',' -f4)))"
        fi
    done <./data/Usage.db
    echo "$time" Total seconds by "$user"
}

most_popular_sim_by_user() {
    lifo=0
    fifo=0
    user=$1
    while IFS= read -r line || [ -n "$line" ]; do
        if echo "$line" | grep -q "User: $user, Action: lifo"; then
            lifo=$((lifo + 1))
        elif echo "$line" | grep -q "User: $user, Action: fifo"; then
            fifo=$((fifo + 1))
        fi
    done <./data/Usage.db

    if [ $lifo -gt $fifo ]; then
        echo "$user used LIFO the most at $lifo times"
    elif [ $lifo -lt $fifo ]; then
        echo "$user used FIFO the most at $fifo times"
    else
        echo "$user had the same usage for both simulators"
    fi
}

# Most popular simulator overall
most_popular_simulator() {
    lifo=0
    fifo=0
    while IFS= read -r line || [ -n "$line" ]; do
        if echo "$line" | grep -q "lifo"; then
            lifo=$((lifo + 1))
        elif echo "$line" | grep -q "fifo"; then
            fifo=$((fifo + 1))
        fi
    done <./data/Usage.db

    if [ $lifo -gt $fifo ]; then
        echo "Most popular simulator: LIFO"
    elif [ $lifo -lt $fifo ]; then
        echo "Most popular simulator: FIFO"
    else
        echo "Most popular simulator: Same usage"
    fi
}

ranking_list() {
    tmp_file=$(mktemp)
    IFS='
' # set the Internal Field Separator to literal newline
    for user in $(jq -r '.users | keys[]' ./data/UPP.json); do
        total_time_by_user "$user" >>"$tmp_file"
    done

    sort -nr -k1 "$tmp_file"

    rm "$tmp_file"
}

while true; do
    clear
    echo "1. Total time by user"
    echo "2. Most popular simulator by user"
    echo "2. Most popular simulator"
    echo "4. Ranking list"
    echo "5. Exit"
    read choice
    case $choice in
    1)
        read -p "Enter username: " user
        if ! check_user_exists "$user"; then
            echo "User does not exist."
            read -p "Press [Enter] key to continue..." readEnterKey
            continue
        fi
        total_time_by_user "$user"
        read -p "Press [Enter] key to continue..." readEnterKey
        ;;
    2)
        read -p "Enter username: " user
        if ! check_user_exists "$user"; then
            echo "User does not exist."
            read -p "Press [Enter] key to continue..." readEnterKey
            continue
        fi
        most_popular_sim_by_user "$user"
        read -p "Press [Enter] key to continue..." readEnterKey
        ;;
    3)
        most_popular_simulator
        read -p "Press [Enter] key to continue..." readEnterKey
        ;;
    4)
        ranking_list
        read -p "Press [Enter] key to continue..." readEnterKey
        ;;
    5)
        exit 0
        ;;
    esac

done
