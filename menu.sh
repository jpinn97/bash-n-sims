#!/bin/bash
# Change to sh

if which bash >/dev/null; then
    true
    # echo "Performing dependency check..."
else
    echo "Bash is not installed, attempting install..."
    if tce-load -wi bash.tcz; then
        echo "Bash installed successfully"
        exec bash
    else
        echo "Bash installation failed"
        exit 1
    fi
fi

IFS= read -r -p "Enter your username: " username
IFS= read -r -s -p "Enter your password: " password

./auth.sh "$username" "$password"

case $? in
    0)  
        echo "Login successful: Welcome $username!";;
    1)  
        echo "Login failed"
        exit 1;;
    *)  
        echo "Unknown error"
        exit 1;;
esac


