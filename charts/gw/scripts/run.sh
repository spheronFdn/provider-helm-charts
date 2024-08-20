#!/bin/bash

# Install apps required by the bid price script
apt -qq update && DEBIAN_FRONTEND=noninteractive apt -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --no-install-recommends install curl jq bc mawk ca-certificates

# fail fast should there be a problem installing curl / jq packages
type curl || exit 1
type jq || exit 1
type awk || exit 1
type bc || exit 1

# Start gateway-services and monitor its output
echo "wallet: $SPHERON_FROM"
echo "home: $SPHERON_HOME"
echo "secret: $SPHERON_KEY_SECRET" ## TODO: Remove this not good for data compliance
env

exec provider-services run \
    --from=$SPHERON_FROM \
    --home=$SPHERON_HOME \
    --key-secret=$SPHERON_KEY_SECRET \
    --gateway-listen-address=0.0.0.0:$SPHERON_API_PORT \
    --bid-price-strategy=$SPHERON_BID_PRICE_STRATEGY \
    --bid-price-script-path=$SPHERON_BID_PRICE_SCRIPT_PATH \
    --deployment-runtime-class=$SPHERON_DEPLOYMENT_RUNTIME_CLASS \
    | while read line; do
    echo "$line"
    if [[ "$line" == *"account sequence mismatch"* ]]; then
        echo "Pattern 'account sequence mismatch' found. Restarting provider-services..."
        exit 2
    fi
done
