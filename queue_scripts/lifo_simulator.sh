#!/bin/ash

read -r -p "LIFO Queue Simulator, do you want to use the pre-defined input? (y/n) " REPLY

while [ "$REPLY" != "y" ] && [ "$REPLY" != "n" ]; do
    read -r -p "Invalid input. Please enter 'y' or 'n': " REPLY
done

input=""

if [ "$REPLY" = "y" ]; then
    input=$(cat ./data/users/simdata_"$1".job)
    if [ -z "$input" ]; then
        echo "No pre-defined input found"
        read -r -p "Enter 10 Byte tasks (comma seperated): " input
        echo "$input" | sudo tee ./data/users/simdata_"$1".job
    fi
else
    read -r -p "Enter 10 Byte tasks (comma seperated): " input
    echo "$input" | sudo tee ./data/users/simdata_"$1".job
fi

queue=""

GREEN='\033[0;32m'
NC='\033[0m'

push() {
    local byte=$1
    if [ -z "$queue" ]; then
        queue="$byte"
    else
        queue="$queue $byte"
    fi
}

display_queue() {
    echo "Current Queue: ${queue}"
}

pop() {
    # Check if queue contains a space
    if echo "$queue" | grep -q ' '; then
        # If queue contains a space, remove the last element
        queue="${queue% *}"
    else
        # If queue doesn't contain a space, set it to an empty string
        queue=""
    fi
}

IFS=','
for byte in $input; do
    sleep 1
    clear
    printf "Pushing ${GREEN}${byte}${NC}"
    push "$byte"
    echo
    echo "LIFO Queue is now: ${queue}"
done

IFS=" "
read -r -p "Press enter to pop the tasks" REPLY

while [ -n "$queue" ]; do
    sleep 1
    clear
    printf "Popping ${GREEN}${byte}${NC}"
    pop
    echo
    echo "LIFO Queue is now: ${queue}"
done
