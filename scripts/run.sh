
if [ -z "$DEMO_WORKSPACE" ]; then
    DEMO_WORKSPACE=~/demo
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

# Once the KMS is running, add a key
echo "Container started"
echo "Waiting for KMS server to start..."
while ! docker exec $CONTAINER_ID /bin/bash -c "lsof -i :8000" > /dev/null 2>&1; do
    sleep 1
done
echo "KMS server started"
echo "Adding Key to KMS..."
docker exec $CONTAINER_ID /bin/bash -c "make setup" > /dev/null 2>&1
echo "Key added"

# Run the B&A servers
(
    cd $DEMO_WORKSPACE/bidding-auction-servers
    source ./env
    ./bazel-bin/services/bidding_service/server --init_config_client="true" &
    ./bazel-bin/services/buyer_frontend_service/server --init_config_client="true" &
    ./bazel-bin/services/auction_service/server --init_config_client="true" &
    ./bazel-bin/services/seller_frontend_service/server --init_config_client="true" &
)

# Wait until the user presses Ctrl+C
cleanup() {
    # Remove the docker container running the KMS
    docker rm -f $CONTAINER_ID > /dev/null 2>&1

    # Stop the B&A servers
    pkill -f bazel-bin

    exit 0
}
echo "B&A services are running, press Ctrl+C to stop..."
trap cleanup SIGINT
while true; do
    sleep 1
done
