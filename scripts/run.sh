# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

if [ -z "$DEMO_WORKSPACE" ]; then
    DEMO_WORKSPACE=~/demo
fi

REPO_PATH=$(realpath $(dirname "$0")/..)

# Check port 8000 is free
if lsof -i :8000 > /dev/null 2>&1; then
    echo "Port 8000 is not free, please stop any process using it and try again"
    exit 1
fi

# Start KMS
(
    cd $DEMO_WORKSPACE/azure-privacy-sandbox-kms
    env -i PATH=$PATH /opt/ccf_virtual/bin/sandbox.sh --js-app-bundle ./dist/ --initial-member-count 3 --initial-user-count 1 --constitution ./governance/constitution/kms_actions.js -v --http2 &
)

# Wait for the KMS to start
response_code=000
while ! [[ $response_code -eq 400 ]]; do
    sleep 1
    response_code=$(curl https://127.0.0.1:8000/app/listpubkeys -k -s -o /dev/null -w "%{http_code}")
done

# Add a key to the KMS
echo "Adding Key to KMS..."
(
    cd $DEMO_WORKSPACE/azure-privacy-sandbox-kms
    env -i PATH=$PATH make setup
)

# Run the B&A servers
declare -A service_pid
(
    cd $DEMO_WORKSPACE/bidding-auction-servers
    source $REPO_PATH/scripts/env
    ./bazel-bin/services/bidding_service/server --init_config_client="true" &
    service_pid["bidding"]=$!
    ./bazel-bin/services/buyer_frontend_service/server --init_config_client="true" &
    service_pid["bfe"]=$!
    ./bazel-bin/services/auction_service/server --init_config_client="true" &
    service_pid["auction"]=$!
    ./bazel-bin/services/seller_frontend_service/server --init_config_client="true" &
    service_pid["sfe"]=$!
)

# Wait until the user presses Ctrl+C
cleanup() {
    pkill -f "python /opt/ccf_virtual/bin/start_network.py" > /dev/null 2>&1
    pkill -f "./bazel-bin/services" > /dev/null 2>&1
    exit 0
}
echo "B&A services are running, press Ctrl+C to stop..."
trap cleanup SIGINT
while true; do
    sleep 1
done
