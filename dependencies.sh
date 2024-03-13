#!/bin/sh

if which jq >/dev/null; then
    true
    # echo "Performing dependency check..."
else
    echo "Jq is not installed, attempting install..."
    sudo mv ./packages/jq-linux-i386 /usr/local/bin/jq
    chmod +x /usr/local/bin/jq
fi