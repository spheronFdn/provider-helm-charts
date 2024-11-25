#!/bin/bash

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "Error: Provider configs URL is required"
    echo "Usage: $0 <provider-configs-url>"
    exit 1
fi

exec provider-services operator inventory \
    --provider-configs-url="$1" | while read line; do
    echo "$line"
    if [[ "$line" == *"unable to start discovery pod on node"* ]]; then
        echo "Pattern 'unable to start discovery pod on node' found. Restarting inventory-services..."
        exit 2
    fi
done
