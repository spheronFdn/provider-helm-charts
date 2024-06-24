#!/bin/bash

# Install apps required by the bid price script
apt -qq update && DEBIAN_FRONTEND=noninteractive apt -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --no-install-recommends install curl jq bc mawk ca-certificates

# fail fast should there be a problem installing curl / jq packages
type curl || exit 1
type jq || exit 1
type awk || exit 1
type bc || exit 1

##
# Wait for RPC
##

##
# Create/Update Provider certs
##
# /scripts/refresh_provider_cert.sh

# Start provider-services and monitor its output
echo "wallet: $SPHERON_FROM"
echo "home: $SPHERON_HOME"
echo "secret: $SPHERON_KEY_SECRET" ## TODO: Remove this not good for data compliance
exec provider-services run --cluster-k8s --from=$SPHERON_FROM --home=$SPHERON_HOME --key-secret=$SPHERON_KEY_SECRET --bid-price-strategy=shellScript --bid-price-script-path=/scripts/price_script.sh | while read line; do
    echo "$line"
    if [[ "$line" == *"account sequence mismatch"* ]]; then
        echo "Pattern 'account sequence mismatch' found. Restarting provider-services..."
        exit 2
    fi
done
