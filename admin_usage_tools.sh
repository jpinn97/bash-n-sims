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
    true
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
        ;;
    3)
        ranking_list
        ;;

    esac

done
