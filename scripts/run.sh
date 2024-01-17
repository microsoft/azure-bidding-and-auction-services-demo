
if [ -z "$DEMO_WORKSPACE" ]; then
    DEMO_WORKSPACE=~/demo
fi

REPO_PATH=$(realpath $(dirname "$0")/..)

# Check port 8000 is free
if lsof -i :8000 > /dev/null 2>&1; then
    echo "Port 8000 is not free, please stop any process using it and try again"
    exit 1
fi

# Start KMS inside a CCF container
echo "Running KMS inside docker container..."
CONTAINER_ID=$(docker run \
    -d \
    -v "$DEMO_WORKSPACE/azure-privacy-sandbox-kms:/workspace" \
    -w /workspace \
    -p 8000:8000 \
    kms \
    /bin/bash -c ". /root/.nvm/nvm.sh && npm install && make start-host")

# Wait for the KMS to start
echo "Container started"
echo "Waiting for KMS server to start..."
LAST_LINE=""
while ! docker exec $CONTAINER_ID /bin/bash -c "lsof -i :8000" > /dev/null 2>&1; do
    CUR_LINE=$(docker logs "$CONTAINER_ID" --tail 1 | cut -c 1-80)
    if [ "$CUR_LINE" != "$LAST_LINE" ]; then
        echo -en "\r\033[K>  $CUR_LINE..."
        LAST_LINE=$CUR_LINE
    fi
done
echo -e "\nKMS server started"

# Add a key to the KMS
echo "Adding Key to KMS..."
docker exec $CONTAINER_ID /bin/bash -c "make setup" > /dev/null 2>&1
echo "Key added"

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
    # Remove the docker container running the KMS
    docker rm -f $CONTAINER_ID > /dev/null 2>&1

    # Stop the B&A servers
    for service in "${!service_pid[@]}"; do
        kill ${service_pid[$service]} 2> /dev/null
    done

    exit 0
}
echo "B&A services are running, press Ctrl+C to stop..."
trap cleanup SIGINT
while true; do
    sleep 1
done
