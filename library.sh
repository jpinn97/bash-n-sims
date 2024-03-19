#!/bin/ash

# Hot reload the library as it may have changed during session
retrieve_user_data() {
    cat ./data/UPP.json
}

# For some prompts, check if "Bye" is entered
read_exit_check() {
    message="$1"
    read -r -p "$message" REPLY
    if [ "$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')" = "bye" ]; then
        read -r -p "Are you sure you want to exit? (y/n) " REPLY
        if [ "$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')" = "y" ]; then
            kill -s TERM $$ # Exit the script forcefully
        else
            echo "Cancelled"
        fi
    else
        echo "$REPLY"
    fi
}

# Regex for validation user, pass, pin
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

# Checks if user exists
user_dir_check() {
    username="$1"
    if ! [ -d /data/users/simdata_"$username".job ]; then
        echo "User directory not found, creating..."
        touch ./data/users/simdata_"$username".job
    fi
}

# Logs user actions to Usage.db
user_logger() {
    case $2 in
    *"Session:"*)
        echo "User: $1, Session: $2, Time: $(date)" >>./data/Usage.db
        return
        ;;
    esac
    echo "User: $1, Action: $2, Time: $(date)" >>./data/Usage.db
    # when user logs in
    # when they logged out?
    # how long they used system for
    # what sims they used
}

# Loading animation
loading() {
    i=1
    while [ "$i" -le 5 ]; do
        echo -n ". "
        sleep 0.5
        i=$((i + 1))
    done
    echo ""
}
