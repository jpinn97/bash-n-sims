#!/bin/ash

# shellcheck disable=SC1091
. ./library.sh

# Load the entire JSON file into a variable
user_data=$(retrieve_user_data)

check_user_exists() {
    username="$1"
    result=$(echo "$user_data" | jq -r ".users | has(\"$newUsername\")")
    if [ "$result" = "true" ]; then
        return 0
    else
        return 1
    fi
}

# Pulls username data from the JSON
get_username_data() {
    username="$1"
    echo "$user_data" | jq -r ".users.${username}"
}

# Create user allows the creation of a username, password, pin, and role, until the information is valid, then rewrites to file
create_user() {
    while true; do
        newUsername=$(read_exit_check "Enter a username: ")
        if validateUsername "$newUsername" && ! check_user_exists "$newUsername"; then
            break
        else
            echo "Username is either not unique or invalid. Please enter a unique valid username (5 alphanumeric characters)."
        fi
    done

    while true; do
        newPassword=$(read_exit_check "Enter a password: ")
        confirmPassword=$(read_exit_check "Confirm password: ")
        if [ "$newPassword" = "$confirmPassword" ] && validatePassword "$newPassword"; then
            break
        else
            echo "Passwords do not match or are invalid. Please enter a valid password (5 alphanumeric characters)."
        fi
    done

    while true; do
        newPin=$(read_exit_check "Enter a pin: ")
        if validatePin "$newPin"; then
            break
        else
            echo "Enter a valid pin (3 digits)."
        fi
    done

    while true; do
        newRole=$(read_exit_check "Enter a role (0 for user, 1 for admin): ")
        if [ "$newRole" -eq 0 ] || [ "$newRole" -eq 1 ]; then
            break
        else
            echo "Invalid role. Please enter 0 for user or 1 for admin."
        fi
    done

    # Create a new user object and add it to the 'users' object
    updated_user_data=$(echo "$user_data" | jq \
        --arg username "$newUsername" \
        --arg password "$newPassword" \
        --arg pin "$newPin" \
        --argjson role "$newRole" \
        '.users[$username] = {role: $role, password: $password, pin: $pin}')

    echo "$updated_user_data" >./data/UPP.json

    read -p "Press [Enter] key to continue..." readEnterKey
}

# If user exists, delete the user and rewrite the file
delete_user() {
    user=$1
    username=$(read_exit_check "Enter a username: ")
    if ! check_user_exists "$username"; then
        updated_user_data=$(echo "$user_data" | jq "del(.users.\"$username\")")
        pin=$(read_exit_check "Enter your pin: ")
        if [ "$pin" = "$(get_username_data "$1" | jq -r '.pin')" ]; then
            echo "$updated_user_data" >./data/UPP.json
        else
            echo "Invalid pin."
        fi
    else
        echo "User does not exist."
    fi
    read -p "Press [Enter] key to continue..." readEnterKey
}

# If user exists, update the user and rewrite the file
update_user() {
    user=$1
    username=$(read_exit_check "Enter a username: ")
    if ! check_user_exists "$username"; then
        while true; do
            newPassword=$(read_exit_check "Enter a new password: ")
            confirmPassword=$(read_exit_check "Confirm new password: ")
            if [ "$newPassword" = "$confirmPassword" ] && validatePassword "$newPassword"; then
                break
            else
                echo "Passwords do not match or are invalid. Please enter a valid password (5 alphanumeric characters)."
            fi
        done

        while true; do
            newPin=$(read_exit_check "Enter a new pin: ")
            if validatePin "$newPin"; then
                break
            else
                echo "Enter a valid pin (3 digits)."
            fi
        done

        pin=$(read_exit_check "Enter your pin: ")
        if [ "$pin" = "$(get_username_data "$user" | jq -r '.pin')" ]; then

            updated_username_data=$(echo "$user_data" | jq \
                --arg username "$username" \
                --arg password "$newPassword" \
                --arg pin "$newPin" \
                '.users[$username].password = $password | .users[$username].pin = $pin')

            echo "$updated_username_data" >./data/UPP.json
        else
            echo "Invalid pin."
        fi
    else
        echo "User does not exist."
    fi
    read -p "Press [Enter] key to continue..." readEnterKey
}

while true; do
    clear
    echo "=================="
    echo "Admin Menu"
    echo "=================="
    echo "1. Create User"
    echo "2. Delete User"
    echo "3. Update User"
    echo "4. Simulation"
    echo "5. User Statistics"
    echo "6. Exit"
    echo "Enter your choice: "
    read choice

    case $choice in
    1)
        echo "Create User"
        create_user
        ;;
    2)
        echo "Delete User"
        delete_user "$1"
        ;;
    3)
        echo "Update User"
        update_user "$1"
        ;;
    4) # Exit the script
        true
        ;;
    5) # User stats
        ./admin_usage_tools.sh
        ;;
    6) # Exit the script
        echo "Bye!"
        exit 0
        ;;
    *)
        echo "Error: Invalid option..."
        read -p "Press [Enter] key to continue..." readEnterKey
        ;;
    esac
    # Reload the user data
    user_data=$(cat ./data/UPP.json)
done
