# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

if [ -z "$DEMO_WORKSPACE" ]; then
    DEMO_WORKSPACE=./workspaces/demo
fi

if [ -z "$TARGET_SERVICE" ]; then
    TARGET_SERVICE=bfe
fi

if [ -z "$REQUEST_PATH" ]; then
    REQUEST_PATH=requests/get_bids_request.json
fi

REPO_PATH=$(realpath $(dirname "$0")/..)

declare -A service_ports
service_ports["bfe"]="50051"
service_ports["sfe"]="50053"
service_ports["bidding"]="50057"
service_ports["auction"]="50061"

echo "Invoking $REQUEST_PATH on $TARGET_SERVICE"

(
    cd $DEMO_WORKSPACE/bidding-auction-servers
    
    ./bazel-bin/tools/secure_invoke/invoke \
        -op=invoke \
        -target_service=$TARGET_SERVICE \
        -input_file=$REPO_PATH/$REQUEST_PATH \
        -input_format=JSON \
        -host_addr="localhost:${service_ports[$TARGET_SERVICE]}" \
        -client_ip=localhost \
        -insecure=true \
        -key_id=$(curl https://127.0.0.1:8000/app/listpubkeys -k -s | jq '.keys[0].id' -r) \
        -public_key=$(curl https://127.0.0.1:8000/app/listpubkeys -k -s | jq '.keys[0].key' -r)
)