#!/bin/ash

retrieve_user_data() {
    cat ./data/UPP.json
}

read_exit_check() {
    message="$1"
    read -r -p "$message" REPLY
    if [ "$REPLY" = "Bye" ]; then
        read -r -p "Are you sure you want to exit? (y/n) " REPLY
        if [ "$REPLY" = "y" ]; then
            kill -s TERM $$ # Exit the script forcefully
        else
            echo "Cancelled"
        fi
    else
        echo "$REPLY"
    fi
}

validateUsername() {
    echo "$1" | grep -Eq "^[a-zA-Z0-9]{5}$"
}

validatePassword() {
    echo "$1" | grep -Eq "^[a-zA-Z0-9]{5}$"
}

validatePin() {
    echo "$1" | grep -Eq "^[0-9]{3}$"
}

user_usage_check() {
    true
}

user_dir_check() {
    username="$1"
    if ! [ -d /data/users/simdata_"$username".job ]; then
        echo "User directory not found, creating..."
        touch ./data/users/simdata_"$username".job
    fi
}