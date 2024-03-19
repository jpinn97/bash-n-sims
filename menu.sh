#!/bin/ash

# Performs installation and executability of dependencies
chmod +x ./*.sh
chmod +x ./queue_scripts/*.sh
./dependencies.sh
# shellcheck disable=SC1091
. ./library.sh

IFS= read -r -p "Enter your username: " username
stty -echo
IFS= read -r -p "Enter your password: " password
stty echo
printf "\n"

./auth.sh "$username" "$password"

case $? in
0)
    echo "Login successful: Welcome $username!"
    loading
    user_dir_check "$username"
    ;;
1)
    echo "[ADMIN] $username logged in"
    user_dir_check "$username"
    ./admin_tools.sh "$username"
    exit 0
    ;;
*)
    echo "Invalid credentials. Exiting..."
    exit 1
    ;;
esac

login_time=$(date +%s)

# Uses jq to read and rewrite password to user
user_change_password() {
    while true; do
        newPassword=$(read_exit_check "Enter a new password: ")
        confirmPassword=$(read_exit_check "Confirm new password: ")
        if [ "$newPassword" = "$confirmPassword" ] && validatePassword "$newPassword"; then
            break
        else
            echo "Passwords do not match or are invalid. Please enter a valid password (5 alphanumeric characters)."
        fi
    done

    user_data=$(retrieve_user_data)
    user_pin=$(echo "$user_data" | jq -r ".users.\"$username\".pin")

    pin=$(read_exit_check "Enter your pin: ")
    if [ "$pin" = "$user_pin" ]; then
        updated_username_data=$(echo "$user_data" | jq \
            --arg username "$username" \
            --arg password "$newPassword" \
            '.users[$username].password = $password')

        echo "$updated_username_data" >./data/UPP.json
    else
        echo "Incorrect pin."
    fi
}

# Logs user out and logs their session
handle_exit() {
    exit_time=$(date +%s)
    time_diff=$((exit_time - login_time))
    user_logger "$username" "Session: $login_time,$exit_time,$time_diff"
    loading
    echo "Bye!"
    exit 0
}

# Catches ungraceful exits
trap handle_exit INT TERM

# ANSI colours
RED='\033[0;31m'
NC='\033[0m'

# Menu
while true; do
    clear
    printf "${RED}"
    echo "===================="
    echo "User Simulation Menu"
    echo "===================="
    echo "1. LIFO Simulation"
    echo "2. FIFO Simulation"
    echo "3. Change Password"
    echo "4. Exit"
    echo "Enter your choice: "
    printf "${NC}"
    read choice

    case $choice in
    1)
        user_logger "$username" "lifo"
        ./queue_scripts/lifo_simulator.sh "$username"
        ;;
    2)
        user_logger "$username" "fifo"
        ./queue_scripts/fifo_simulator.sh "$username"
        ;;
    3)
        user_logger "$username" "passwd"
        user_change_password
        ;;
    4) # Exit the script
        handle_exit
        ;;
    *)
        echo "Error: Invalid option..."
        read -p "Press [Enter] key to continue..." readEnterKey
        ;;
    esac
    # Reload the user data
    user_data=$(cat ./data/UPP.json)
done
