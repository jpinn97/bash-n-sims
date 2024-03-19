#!/bin/ash

total_time_by_user() {
    user=$1
    local time=0
    while IFS= read -r line; do
        if echo "$line" | grep -q "User: $user, Action: Session:"; then
            time="$((time + $(echo "$line" | cut -d',' -f4)))"
        fi
    done <./data/Usage.db
    echo "Total time by ""$user": "$time" seconds
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

# Ranking list of the users who have used the system the most
ranking_list() {
    true
}

while true; do
    clear
    echo "1. Total time by user"
    echo "2. Most popular simulator"
    echo "3. Ranking list"
    read choice
    case $choice in
    1)
        read -p "Enter username: " user
        total_time_by_user "$user"
        read -p "Press [Enter] key to continue..." readEnterKey
        ;;
    2)
        most_popular_simulator
        read -p "Press [Enter] key to continue..." readEnterKey
        ;;
    3)
        ranking_list
        read -p "Press [Enter] key to continue..." readEnterKey
        ;;

    esac

done
