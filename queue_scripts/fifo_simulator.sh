#!/bin/ash

read -r -p "FIFO Queue Simulator, do you want to use the pre-defined input? (y/n) " REPLY

while [ "$REPLY" != "y" ] && [ "$REPLY" != "n" ]; do
    read -r -p "Invalid input. Please enter 'y' or 'n': " REPLY
done

input=""

if [ "$REPLY" = "y" ]; then
    input=$(cat ./data/users/simdata_"$1".job)
    if [ -z "$input" ]; then
        echo "No pre-defined input found"
        read -r -p "Enter 10 Byte tasks (comma seperated): " input
        echo "$input" >./data/users/simdata_"$1".job
    fi
else
    read -r -p "Enter 10 Byte tasks (comma seperated): " input
    echo "$input" >./data/users/simdata_"$1".job
fi

queue=""

GREEN='\033[0;32m'
NC='\033[0m'

# Add a byte to the queue
enqueue() {
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

# Takes the first element off the queue
dequeue() {
    # Check if queue contains a space
    if echo "$queue" | grep -q ' '; then
        # If queue contains a space, remove the first element
        queue=$(echo "$queue" | cut -d' ' -f2-)
    else
        # If queue doesn't contain a space, set it to an empty string
        queue=""
    fi
}

# Loop over string splitting and enqueueing each byte
IFS=','
for byte in $input; do
    sleep 1
    clear
    printf "Enqueueing ${GREEN}${byte}${NC}"
    enqueue "$byte"
    echo "FIFO Queue is now: ${queue}"
done

IFS=" "
read -r -p "Press enter to dequeue the tasks" REPLY

# Loop over the queue, dequeueing each byte
for byte in $queue; do
    sleep 1
    clear
    printf "Dequeueing ${GREEN}${byte}${NC}"
    dequeue
    echo "FIFO Queue is now: ${queue}"
done
