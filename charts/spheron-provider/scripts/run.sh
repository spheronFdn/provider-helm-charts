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
exec provider-services run \
    --cluster-k8s \
    --from=$SPHERON_FROM \
    --home=$SPHERON_HOME \
    --key-secret=$SPHERON_KEY_SECRET \
    --bid-price-strategy=$SPHERON_BID_PRICE_STRATEGY \
    --bid-price-script-path=$SPHERON_BID_PRICE_SCRIPT_PATH \
    --deployment-ingress-static-hosts=$SPHERON_DEPLOYMENT_INGRESS_STATIC_HOSTS \
    --deployment-ingress-domain=$SPHERON_DEPLOYMENT_INGRESS_DOMAIN \
    --cluster-node-port-quantity=$SPHERON_CLUSTER_NODE_PORT_QUANTITY \
    --cluster-public-hostname=$SPHERON_CLUSTER_PUBLIC_HOSTNAME \
    --deployment-runtime-class=$SPHERON_DEPLOYMENT_RUNTIME_CLASS \
    | while read line; do
    echo "$line"
    if [[ "$line" == *"account sequence mismatch"* ]]; then
        echo "Pattern 'account sequence mismatch' found. Restarting provider-services..."
        exit 2
    fi
done
